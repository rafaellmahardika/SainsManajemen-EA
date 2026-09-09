#property strict
#property version   "1.00"

#include <Trade/Trade.mqh>
CTrade trade;

input group "=== Risk & Execution ==="
input double InpRiskPercent      = 1.0;
input double InpFixedLot         = 0.10;
input bool   InpUseRiskSizing    = true;
input int    InpMagic            = 260909;
input int    InpMaxSpreadPoints  = 50;
input int    InpSlippagePoints   = 20;
input bool   InpOnePositionOnly  = true;

input group "=== Structure ==="
input int    InpPivotLeft        = 3;
input int    InpPivotRight       = 3;
input int    InpStructureLookback= 120;
input int    InpBreakBufferPts   = 20;

input group "=== Volatility / Exit ==="
input int    InpATRPeriod        = 14;
input double InpSL_ATR            = 1.5;
input double InpTP_RR             = 2.0;
input bool   InpUseTrailing       = true;
input double InpTrailATR          = 1.2;

datetime g_lastBar = 0;

// ---------- Utilities ----------
bool IsNewBar()
{
   datetime t = iTime(_Symbol, _Period, 0);
   if(t == 0 || t == g_lastBar) return false;
   g_lastBar = t;
   return true;
}

bool SpreadOK()
{
   long spread = 0;
   if(!SymbolInfoInteger(_Symbol, SYMBOL_SPREAD, spread)) return false;
   return (spread <= InpMaxSpreadPoints);
}

int DigitsForSymbol() { return (int)SymbolInfoInteger(_Symbol, SYMBOL_DIGITS); }

double NormPrice(double p)
{
   return NormalizeDouble(p, DigitsForSymbol());
}

double PointValuePerLot()
{
   double tick_value=0.0, tick_size=0.0;
   SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_VALUE, tick_value);
   SymbolInfoDouble(_Symbol, SYMBOL_TRADE_TICK_SIZE, tick_size);
   if(tick_size <= 0.0) return 0.0;
   return tick_value / tick_size;
}

double CalcLot(double entry, double sl)
{
   if(!InpUseRiskSizing) return InpFixedLot;
   double risk_money = AccountInfoDouble(ACCOUNT_EQUITY) * InpRiskPercent / 100.0;
   double dist = MathAbs(entry-sl);
   double pv = PointValuePerLot();
   if(risk_money <= 0 || dist <= 0 || pv <= 0) return InpFixedLot;
   double lot = risk_money / (dist * pv);

   double step=0.01, minlot=0.01, maxlot=100.0;
   SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_STEP, step);
   SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MIN, minlot);
   SymbolInfoDouble(_Symbol, SYMBOL_VOLUME_MAX, maxlot);
   lot = MathFloor(lot/step)*step;
   lot = MathMax(minlot, MathMin(maxlot, lot));
   return lot;
}

bool HasOurPosition()
{
   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)==_Symbol &&
         (int)PositionGetInteger(POSITION_MAGIC)==InpMagic)
         return true;
   }
   return false;
}

double iATRValue(int period, int shift);

void TrailPositions()
{
   if(!InpUseTrailing) return;
   double atr = iATRValue(InpATRPeriod, 1);
   if(atr <= 0) return;

   for(int i=PositionsTotal()-1;i>=0;i--)
   {
      ulong ticket=PositionGetTicket(i);
      if(ticket==0) continue;
      if(PositionGetString(POSITION_SYMBOL)!=_Symbol ||
         (int)PositionGetInteger(POSITION_MAGIC)!=InpMagic) continue;

      ENUM_POSITION_TYPE type=(ENUM_POSITION_TYPE)PositionGetInteger(POSITION_TYPE);
      double sl=PositionGetDouble(POSITION_SL);
      double tp=PositionGetDouble(POSITION_TP);
      double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
      double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);

      if(type==POSITION_TYPE_BUY)
      {
         double new_sl=NormPrice(bid-atr*InpTrailATR);
         if((sl==0 || new_sl>sl) && new_sl<bid)
            trade.PositionModify(ticket,new_sl,tp);
      }
      else if(type==POSITION_TYPE_SELL)
      {
         double new_sl=NormPrice(ask+atr*InpTrailATR);
         if((sl==0 || new_sl<sl) && new_sl>ask)
            trade.PositionModify(ticket,new_sl,tp);
      }
   }
}

double iATRValue(int period, int shift)
{
   MqlRates r[];
   int n=period+shift+2;
   ArraySetAsSeries(r,true);
   if(CopyRates(_Symbol,_Period,0,n,r)<n) return 0;
   double sum=0;
   for(int i=shift;i<shift+period;i++)
   {
      double prev_close=r[i+1].close;
      double tr=MathMax(r[i].high-r[i].low,
                 MathMax(MathAbs(r[i].high-prev_close),MathAbs(r[i].low-prev_close)));
      sum+=tr;
   }
   return sum/period;
}

double SMA(int period,int shift)
{
   MqlRates r[];
   ArraySetAsSeries(r,true);
   if(CopyRates(_Symbol,_Period,0,period+shift+1,r)<period+shift+1) return 0;
   double s=0;
   for(int i=shift;i<shift+period;i++) s+=r[i].close;
   return s/period;
}

double RSI(int period,int shift)
{
   MqlRates r[];
   ArraySetAsSeries(r,true);
   int n=period+shift+2;
   if(CopyRates(_Symbol,_Period,0,n,r)<n) return 50;
   double gain=0,loss=0;
   for(int i=shift;i<shift+period;i++)
   {
      double d=r[i].close-r[i+1].close;
      if(d>0) gain+=d; else loss-=d;
   }
   if(loss==0) return 100;
   double rs=(gain/period)/(loss/period);
   return 100.0-(100.0/(1.0+rs));
}

bool IsPivotHigh(const MqlRates &r[],int idx,int left,int right)
{
   for(int k=1;k<=left;k++)  if(r[idx].high<=r[idx+k].high) return false;
   for(int k=1;k<=right;k++) if(r[idx].high<=r[idx-k].high) return false;
   return true;
}
bool IsPivotLow(const MqlRates &r[],int idx,int left,int right)
{
   for(int k=1;k<=left;k++)  if(r[idx].low>=r[idx+k].low) return false;
   for(int k=1;k<=right;k++) if(r[idx].low>=r[idx-k].low) return false;
   return true;
}

bool GetLastTwoPivots(double &ph1,double &ph2,double &pl1,double &pl2)
{
   MqlRates r[];
   ArraySetAsSeries(r,true);
   int need=InpStructureLookback+InpPivotLeft+InpPivotRight+10;
   if(CopyRates(_Symbol,_Period,0,need,r)<need) return false;

   ph1=ph2=pl1=pl2=0;
   int hc=0,lc=0;
   for(int i=InpPivotRight+1;i<InpStructureLookback;i++)
   {
      if(hc<2 && IsPivotHigh(r,i,InpPivotLeft,InpPivotRight))
      {
         if(hc==0) ph1=r[i].high; else ph2=r[i].high;
         hc++;
      }
      if(lc<2 && IsPivotLow(r,i,InpPivotLeft,InpPivotRight))
      {
         if(lc==0) pl1=r[i].low; else pl2=r[i].low;
         lc++;
      }
      if(hc>=2 && lc>=2) break;
   }
   return (hc>=2 && lc>=2);
}

int TrendState()
{
   double ph1,ph2,pl1,pl2;
   if(!GetLastTwoPivots(ph1,ph2,pl1,pl2)) return 0;
   if(ph1>ph2 && pl1>pl2) return 1;
   if(ph1<ph2 && pl1<pl2) return -1;
   return 0;
}

void OpenBuy(double sl,double tp)
{
   double ask=SymbolInfoDouble(_Symbol,SYMBOL_ASK);
   double lot=CalcLot(ask,sl);
   trade.Buy(lot,_Symbol,ask,NormPrice(sl),NormPrice(tp),"MS-EA BUY");
}

void OpenSell(double sl,double tp)
{
   double bid=SymbolInfoDouble(_Symbol,SYMBOL_BID);
   double lot=CalcLot(bid,sl);
   trade.Sell(lot,_Symbol,bid,NormPrice(sl),NormPrice(tp),"MS-EA SELL");
}


int OnInit(){ trade.SetExpertMagicNumber(InpMagic); trade.SetDeviationInPoints(InpSlippagePoints); return INIT_SUCCEEDED; }
void OnTick(){
   TrailPositions();
   if(!IsNewBar()||!SpreadOK()) return;
   if(InpOnePositionOnly&&HasOurPosition()) return;
   MqlRates r[]; ArraySetAsSeries(r,true); if(CopyRates(_Symbol,_Period,0,10,r)<10)return;
   double ph1,ph2,pl1,pl2; if(!GetLastTwoPivots(ph1,ph2,pl1,pl2))return;
   double c=r[1].close,atr=iATRValue(InpATRPeriod,1),buffer=InpBreakBufferPts*_Point;
   if(c>ph1+buffer){double sl=pl1-0.25*atr,tp=c+(c-sl)*InpTP_RR;OpenBuy(sl,tp);}
   else if(c<pl1-buffer){double sl=ph1+0.25*atr,tp=c-(sl-c)*InpTP_RR;OpenSell(sl,tp);}
}
