# Market Structure Trend Following EA

Rafael Mahardika Arya Dewamurti
24/536279/PA/22755

> **A Comparative Study of 10 Market Structure-Based Expert Advisors (EA) for MetaTrader 5**

Repository ini merupakan bagian dari proyek mata kuliah **Sains/Manajemen** yang berfokus pada perancangan, implementasi, pengujian, dan optimasi **Expert Advisor (EA)** pada platform **MetaTrader 5 (MT5)**.

Penelitian ini menggunakan tema utama **Market Structure Trend Following**, dengan mengembangkan beberapa pendekatan berbasis struktur harga yang kemudian dibandingkan melalui proses **backtesting, optimization, dan forward/out-of-sample testing**.

---

## 1. Project Overview

Market Structure Trend Following merupakan pendekatan trading yang berusaha mengidentifikasi arah pasar berdasarkan perubahan struktur harga.

Struktur harga secara umum dapat diamati melalui pola seperti:

* **Higher High (HH)**
* **Higher Low (HL)**
* **Lower High (LH)**
* **Lower Low (LL)**
* **Break of Structure (BOS)**
* **Change of Character (CHoCH)**

Pada penelitian ini, konsep tersebut dikembangkan menjadi **10 varian Expert Advisor**.

Tujuan utama pengembangan 10 EA bukan hanya mencari EA dengan profit tertinggi, tetapi untuk mengetahui bagaimana perbedaan rule entry, confirmation, filtering, dan exit memengaruhi performa sistem automated trading.

---

## 2. Reference

### Main Reference

**Channel:** René Balke – Fx Bot Trading / BM Trading

**Video:**

> *Copy My Prompts: Claude AI Codes a 5-Year Profitable MetaTrader 5 EA (Step-by-Step)*

**YouTube:**

https://www.youtube.com/watch?v=mGG0nu8A9FU

Video tersebut digunakan sebagai **referensi konseptual dan implementasi**, khususnya dalam pengembangan EA berbasis market structure menggunakan bantuan AI.

> **Important Note:**
> Judul video mengandung klaim mengenai profitability selama periode tertentu. Klaim tersebut tidak dianggap sebagai bukti profitabilitas penelitian ini. Seluruh performa EA dalam repository ini harus diverifikasi secara independen melalui backtesting, optimization, dan forward/out-of-sample testing.

---

# 3. Research Objective

Penelitian ini memiliki beberapa tujuan:

1. Mengimplementasikan konsep market structure ke dalam Expert Advisor berbasis MQL5.
2. Mengembangkan beberapa variasi strategi market structure.
3. Membandingkan performa masing-masing EA menggunakan kondisi pengujian yang konsisten.
4. Mengidentifikasi EA yang memiliki performa baseline paling menjanjikan.
5. Melakukan optimization terhadap EA yang terpilih.
6. Menguji robustness parameter hasil optimization menggunakan forward atau out-of-sample testing.
7. Menganalisis hubungan antara strategi, profitabilitas historis, risiko, jumlah transaksi, dan drawdown.

---

# 4. Research Workflow

Penelitian dilakukan secara bertahap.

```text
                    MARKET STRUCTURE CONCEPT
                              │
                              ▼
                     EA DESIGN & CODING
                              │
                              ▼
                     10 BASELINE EAs
                              │
                              ▼
                     MT5 BACKTESTING
                     Optimization OFF
                              │
                              ▼
                 PERFORMANCE COMPARISON
                              │
                              ▼
                   EA SCREENING / SELECTION
                              │
                              ▼
                   PARAMETER OPTIMIZATION
                              │
                              ▼
                    BEST PARAMETER SET
                              │
                              ▼
                 FORWARD / OUT-OF-SAMPLE TEST
                              │
                              ▼
                    FINAL COMPARISON
                              │
                              ▼
                 ROBUSTEST EA CANDIDATE
```

Tahap baseline dilakukan terlebih dahulu terhadap seluruh EA agar setiap strategi dapat dibandingkan sebelum dilakukan tuning parameter.

Optimization kemudian dilakukan hanya terhadap EA yang memenuhi kriteria screening yang telah ditentukan.

---

# 5. The 10 Expert Advisors

Penelitian ini terdiri dari 10 Expert Advisor yang memiliki tema utama yang sama, tetapi menggunakan mekanisme konfirmasi dan exit yang berbeda.

| EA   | Strategy                  | Core Concept                                      |
| ---- | ------------------------- | ------------------------------------------------- |
| EA01 | Market Structure Breakout | Break of Structure (BOS)                          |
| EA02 | Swing Structure Trend     | Higher High + Higher Low / Lower High + Lower Low |
| EA03 | BOS + MA Filter           | BOS + trend filter                                |
| EA04 | BOS + RSI Confirmation    | BOS + momentum confirmation                       |
| EA05 | CHoCH Trend Reversal      | Change of Character                               |
| EA06 | Breakout + ATR Filter     | Market structure + volatility filter              |
| EA07 | Pullback Structure        | BOS → retracement → continuation                  |
| EA08 | Multi-Timeframe Structure | HTF structure + LTF entry                         |
| EA09 | Structure + Trailing Stop | Structure entry + dynamic exit                    |
| EA10 | Adaptive Market Structure | Structure + trend + volatility regime             |

Setiap EA dibuat sebagai file `.mq5` yang berdiri sendiri sehingga dapat diuji secara independen pada MetaTrader 5 Strategy Tester.

---

# 6. Strategy Description

## EA01 — Market Structure Breakout

EA01 berfokus pada **Break of Structure (BOS)**.

Sistem mengidentifikasi swing high dan swing low kemudian mendeteksi ketika harga menembus struktur penting tersebut.

### Basic Logic

**Buy:**

```text
Price > Previous Swing High
```

**Sell:**

```text
Price < Previous Swing Low
```

Stop Loss ditempatkan berdasarkan struktur berlawanan dengan tambahan volatility buffer.

Take Profit menggunakan risk-reward ratio.

---

## EA02 — Swing Structure Trend

EA02 mencoba menentukan arah trend berdasarkan hubungan antara swing points.

### Bullish Structure

```text
Higher High
+
Higher Low
```

### Bearish Structure

```text
Lower High
+
Lower Low
```

EA hanya mengambil posisi yang sesuai dengan arah struktur yang telah teridentifikasi.

---

## EA03 — BOS + Moving Average Filter

EA03 menggabungkan:

```text
Break of Structure
+
Moving Average Trend Filter
```

Breakout bullish hanya dipertimbangkan ketika moving average menunjukkan kondisi bullish.

Breakout bearish hanya dipertimbangkan ketika moving average menunjukkan kondisi bearish.

Tujuannya adalah mengurangi breakout yang berlawanan dengan trend dominan.

---

## EA04 — BOS + RSI Confirmation

EA04 menggabungkan struktur harga dan momentum.

### Buy

```text
Bullish BOS
+
RSI > Buy Threshold
```

### Sell

```text
Bearish BOS
+
RSI < Sell Threshold
```

RSI digunakan sebagai filter tambahan untuk menghindari sebagian breakout yang tidak memiliki momentum cukup.

---

## EA05 — CHoCH Trend Reversal

EA05 berfokus pada **Change of Character (CHoCH)**.

Konsep dasarnya adalah mencari indikasi bahwa struktur pasar mulai berubah.

Contoh:

```text
Bearish Structure
       ↓
Price breaks previous structure
       ↓
Bullish CHoCH
       ↓
Potential Buy
```

Pendekatan serupa diterapkan untuk perubahan bullish menuju bearish.

---

## EA06 — Breakout + ATR Filter

EA06 menggunakan:

```text
Market Structure Breakout
+
ATR Volatility Filter
```

Breakout hanya diperbolehkan ketika kondisi volatilitas berada dalam range yang telah ditentukan.

Tujuannya adalah membatasi entry ketika market terlalu tenang ataupun terlalu ekstrem.

---

## EA07 — Pullback Structure

Berbeda dengan EA yang langsung melakukan entry ketika BOS terjadi, EA07 berusaha menunggu pullback.

Model konseptual:

```text
Structure Break
       ↓
Trend Confirmation
       ↓
Retracement / Pullback
       ↓
Continuation Confirmation
       ↓
Entry
```

Pendekatan ini bertujuan mendapatkan entry yang lebih dekat dengan area retracement daripada mengejar breakout secara langsung.

---

## EA08 — Multi-Timeframe Structure

EA08 menggunakan lebih dari satu timeframe.

Contoh:

```text
Higher Timeframe
      ↓
Determine Market Structure / Bias
      ↓
Lower Timeframe
      ↓
Find Entry
```

Higher timeframe digunakan untuk menentukan arah dominan, sedangkan lower timeframe digunakan untuk mencari trigger entry yang lebih presisi.

---

## EA09 — Structure + Trailing Stop

EA09 menggunakan market structure untuk entry, kemudian menggunakan **ATR-based trailing stop** untuk pengelolaan posisi.

Tujuan utamanya adalah memberikan ruang bagi trend untuk berkembang sambil secara bertahap mengunci keuntungan.

---

## EA10 — Adaptive Market Structure

EA10 merupakan varian yang paling kompleks.

Strategy ini menggabungkan:

```text
Market Structure
+
Moving Average Trend
+
RSI
+
Volatility
+
Efficiency Ratio
```

Efficiency Ratio digunakan sebagai indikator sederhana untuk membedakan market yang lebih directional dari market yang lebih noisy.

Model adaptif kemudian hanya mengambil setup apabila kondisi trend dan market regime memenuhi kriteria tertentu.

---

# 7. Common EA Features

Sebagian besar EA dalam repository menggunakan beberapa mekanisme yang sama agar eksperimen lebih konsisten.

### Risk-Based Position Sizing

Ukuran posisi dapat dihitung berdasarkan persentase risiko terhadap equity.

```text
Risk Money
=
Account Equity × Risk Percentage
```

Ukuran lot kemudian disesuaikan berdasarkan jarak entry terhadap Stop Loss dan karakteristik symbol.

---

### Stop Loss

Stop Loss menggunakan struktur harga dan/atau ATR.

Contoh:

```text
SL = Structure Level ± ATR Buffer
```

---

### Take Profit

Take Profit menggunakan pendekatan risk-reward.

Contoh:

```text
TP = Entry + (Risk × RR)
```

untuk posisi Buy.

---

### Spread Filter

EA memiliki batas maksimum spread agar entry tidak dilakukan ketika biaya transaksi relatif tinggi.

---

### Magic Number

Setiap EA menggunakan magic number untuk membantu identifikasi posisi yang dibuka oleh EA.

---

### One Position Mode

EA dapat dikonfigurasi agar hanya mempertahankan satu posisi aktif pada symbol dan magic number tertentu.

---

### New-Bar Detection

Sinyal utama diproses berdasarkan bar baru untuk menghindari eksekusi berulang pada candle yang sama.

---

# 8. Repository Structure

Struktur repository dirancang agar kode, dokumentasi, dan hasil eksperimen dapat dipisahkan.

```text
market-structure-trend-following-ea/
│
├── EAs/
│   │
│   ├── EA01_Market_Structure_Breakout.mq5
│   ├── EA02_Swing_Structure_Trend.mq5
│   ├── EA03_BOS_MA_Filter.mq5
│   ├── EA04_BOS_RSI_Confirmation.mq5
│   ├── EA05_CHoCH_Trend_Reversal.mq5
│   ├── EA06_Breakout_ATR_Filter.mq5
│   ├── EA07_Pullback_Structure.mq5
│   ├── EA08_MTF_Structure.mq5
│   ├── EA09_Structure_Trailing_Stop.mq5
│   └── EA10_Adaptive_Market_Structure.mq5
│
├── results/
│   │
│   ├── EA01/
│   ├── EA02/
│   ├── EA03/
│   ├── EA04/
│   ├── EA05/
│   ├── EA06/
│   ├── EA07/
│   ├── EA08/
│   ├── EA09/
│   └── EA10/
│
├── optimization/
│   │
│   ├── EA02/
│   ├── EA04/
│   ├── EA06/
│   ├── EA08/
│   └── EA10/
│
├── report/
│   │
│   └── research-report/
│
├── illustrative_backtest.py
├── illustrative_backtest_results.csv
├── illustrative_equity_curves.png
├── README.md
└── LICENSE
```

Folder optimization dapat disesuaikan setelah hasil baseline diperoleh.

EA yang dimasukkan ke folder optimization nantinya adalah EA yang lolos tahap screening.

---

# 9. MetaTrader 5 Workflow

Proses menjalankan EA dilakukan menggunakan MetaTrader 5 dan MetaEditor.

## Step 1 — Copy `.mq5`

File EA ditempatkan pada folder:

```text
MQL5/Experts/
```

atau subfolder seperti:

```text
MQL5/Experts/MarketStructure/
```

---

## Step 2 — Open in MetaEditor

Buka file `.mq5` melalui MetaEditor.

---

## Step 3 — Compile

Gunakan:

```text
F7
```

Target:

```text
0 errors
0 warnings
```

Jika berhasil, MetaEditor akan menghasilkan file:

```text
EA_Name.ex5
```

File `.ex5` merupakan hasil kompilasi yang digunakan oleh MetaTrader 5.

---

# 10. Backtesting

Backtesting dilakukan menggunakan:

```text
MetaTrader 5
→ View
→ Strategy Tester
```

atau:

```text
Ctrl + R
```

### Baseline Configuration

Konfigurasi baseline harus dibuat konsisten untuk seluruh EA.

Contoh:

| Parameter       | Baseline                       |
| --------------- | ------------------------------ |
| Symbol          | EURUSD                         |
| Timeframe       | H1                             |
| Initial Deposit | 10,000                         |
| Model           | Every tick based on real ticks |
| Optimization    | Disabled                       |
| Testing Period  | Same period for all EA         |

Nilai akhir dapat disesuaikan berdasarkan kebutuhan eksperimen dan data historis yang tersedia.

---

# 11. Baseline Backtest

Baseline backtest dilakukan dengan:

```text
Optimization = Disabled
```

Tujuan baseline adalah mengukur performa masing-masing EA menggunakan parameter awal sebelum dilakukan tuning.

Setiap EA harus diuji dengan kondisi pasar, symbol, timeframe, deposit, dan periode pengujian yang sama sejauh memungkinkan.

---

# 12. Metrics

Beberapa metrik yang akan dicatat:

### Net Profit

Keuntungan bersih yang diperoleh selama periode pengujian.

### Profit Factor

Perbandingan antara gross profit dengan gross loss.

```text
Profit Factor =
Gross Profit / Gross Loss
```

### Maximum Drawdown

Penurunan terbesar dari puncak equity/balance.

### Total Trades

Jumlah transaksi yang dilakukan EA.

### Win Rate

Proporsi transaksi yang menghasilkan profit.

### Expected Payoff

Rata-rata hasil per transaksi.

### Recovery Factor

Digunakan sebagai indikator tambahan untuk melihat hubungan profit terhadap drawdown.

### Sharpe Ratio

Digunakan apabila tersedia pada hasil Strategy Tester dan diperlukan untuk analisis risk-adjusted performance.

---

# 13. EA Screening

Setelah seluruh baseline backtest selesai, hasil akan dibandingkan.

Contoh format:

| EA   | Net Profit | Profit Factor | Max DD | Trades | Win Rate | Expected Payoff |
| ---- | ---------: | ------------: | -----: | -----: | -------: | --------------: |
| EA01 |          - |             - |      - |      - |        - |               - |
| EA02 |          - |             - |      - |      - |        - |               - |
| EA03 |          - |             - |      - |      - |        - |               - |
| EA04 |          - |             - |      - |      - |        - |               - |
| EA05 |          - |             - |      - |      - |        - |               - |
| EA06 |          - |             - |      - |      - |        - |               - |
| EA07 |          - |             - |      - |      - |        - |               - |
| EA08 |          - |             - |      - |      - |        - |               - |
| EA09 |          - |             - |      - |      - |        - |               - |
| EA10 |          - |             - |      - |      - |        - |               - |

Nilai akan diisi berdasarkan hasil aktual dari MetaTrader 5 Strategy Tester.

---

# 14. Optimization

Optimization tidak dilakukan secara membabi buta terhadap seluruh parameter.

Tahap yang digunakan dalam penelitian:

```text
10 EA Baseline
      ↓
Performance Screening
      ↓
Select Promising Candidates
      ↓
Parameter Optimization
```

Dengan demikian, optimization berfungsi untuk mencari konfigurasi parameter yang lebih baik dari baseline sekaligus mengurangi risiko overfitting akibat terlalu banyak melakukan tuning pada seluruh strategi.

---

# 15. Optimization Parameters

Beberapa parameter yang dapat dioptimasi tergantung pada EA:

```text
Fast MA Period
Slow MA Period
ATR Period
SL ATR Multiplier
TP Risk/Reward
Trailing ATR
RSI Period
RSI Threshold
Breakout Buffer
Structure Lookback
Pivot Left
Pivot Right
```

Optimization dilakukan dengan menentukan:

```text
Start
Step
Stop
```

untuk parameter yang dipilih.

Contoh:

```text
Fast MA
Start = 10
Step  = 10
Stop  = 50
```

sehingga tester mengevaluasi:

```text
10
20
30
40
50
```

---

# 16. Optimization Criterion

Optimization dapat menggunakan metrik seperti:

* Balance
* Profit Factor
* Expected Payoff
* Custom Criterion

Profit tertinggi tidak otomatis dianggap sebagai parameter terbaik.

Parameter harus dilihat bersama:

```text
Profit
+
Profit Factor
+
Drawdown
+
Number of Trades
+
Stability
```

---

# 17. Avoiding Overfitting

Salah satu risiko utama dalam optimization adalah **overfitting**.

Overfitting terjadi ketika parameter terlalu disesuaikan dengan data historis tertentu sehingga performanya terlihat sangat baik pada data tersebut tetapi menurun ketika digunakan pada data baru.

Oleh karena itu digunakan pemisahan data:

```text
Historical Data
      │
      ├───────────────┐
      ▼               ▼
 In-Sample       Out-of-Sample
      │               │
      ▼               │
 Optimization         │
      │               │
      └──────► Final Parameter
                       │
                       ▼
                 Forward Test
```

Contoh pembagian:

```text
2021–2023
→ In-Sample / Optimization

2024–2025
→ Out-of-Sample / Forward Test
```

Pembagian periode dapat disesuaikan dengan kebutuhan penelitian.

---

# 18. Forward / Out-of-Sample Test

Setelah parameter terbaik diperoleh dari optimization:

1. Parameter dikunci.
2. Optimization dimatikan.
3. EA diuji pada periode yang tidak digunakan dalam optimization.
4. Hasil dibandingkan dengan hasil in-sample.

Contoh:

```text
Optimization Result
PF = 1.70
Max DD = 12%

          ↓

Forward Result
PF = 1.32
Max DD = 16%
```

Perbedaan performa merupakan hal yang wajar.

Yang lebih penting adalah apakah strategi masih menunjukkan performa yang relatif stabil pada data yang tidak digunakan untuk optimization.

---

# 19. Result Storage

Setiap hasil eksperimen disimpan secara terpisah.

Contoh:

```text
results/
│
├── EA01/
│   ├── report.pdf
│   ├── graph.png
│   └── settings.txt
│
├── EA02/
│   ├── report.pdf
│   ├── graph.png
│   └── settings.txt
│
└── ...
```

Untuk EA yang masuk tahap optimization:

```text
optimization/
│
├── EA02/
│   ├── optimization-results.html
│   ├── best-parameters.txt
│   └── forward-test.pdf
│
└── ...
```

---

# 20. What Will Be Analyzed

Analisis akhir penelitian akan membandingkan:

### Baseline Performance

Bagaimana performa masing-masing EA sebelum optimization.

### Strategy Characteristics

Bagaimana perbedaan rule menghasilkan perilaku yang berbeda.

### Risk

Bagaimana drawdown dan jumlah transaksi dibandingkan dengan profit yang dihasilkan.

### Parameter Sensitivity

Apakah perubahan parameter tertentu memberikan perubahan performa yang ekstrem atau relatif stabil.

### Optimization Improvement

Apakah optimization benar-benar meningkatkan performa dibandingkan baseline.

### Out-of-Sample Robustness

Apakah parameter hasil optimization masih memberikan performa yang masuk akal pada data baru.

---

# 21. Important Research Limitation

Hasil backtest merupakan hasil simulasi historis dan tidak menjamin performa pada kondisi pasar di masa depan.

Beberapa faktor yang dapat memengaruhi hasil antara lain:

* spread,
* commission,
* slippage,
* kualitas historical data,
* execution model,
* broker,
* symbol specification,
* timeframe,
* market regime,
* dan parameter EA.

Karena itu, hasil penelitian harus dipahami sebagai **evaluasi eksperimental terhadap strategi automated trading**, bukan sebagai jaminan profitabilitas pada trading real account.

---

# 22. Current Project Status

### Completed

* [x] Definisi topik penelitian
* [x] Pemilihan referensi utama
* [x] Perancangan 10 variasi EA
* [x] Implementasi baseline `.mq5`
* [x] Struktur repository
* [x] Rancangan baseline backtest
* [x] Rancangan optimization
* [x] Rancangan forward/out-of-sample testing

### In Progress

* [ ] Compile seluruh EA di MetaEditor
* [ ] Baseline backtest EA01–EA10
* [ ] Comparative analysis
* [ ] Screening kandidat optimization
* [ ] Parameter optimization
* [ ] Forward/out-of-sample testing
* [ ] Final report

---

# 23. Reproducibility

Agar eksperimen dapat direproduksi, setiap hasil sebaiknya menyimpan:

```text
EA Version
Symbol
Timeframe
Testing Period
Initial Deposit
Model
Spread Setting
Commission
EA Inputs
Optimization Settings
Optimization Period
Forward Period
Final Parameters
```

Dengan informasi tersebut, eksperimen dapat dijalankan ulang dengan konfigurasi yang sama.

---

# 24. Disclaimer

This repository is created for **academic research and educational purposes**.

The strategies and Expert Advisors contained in this repository are experimental implementations intended for backtesting and comparative analysis.

No performance result in this repository should be interpreted as a guarantee of future trading performance or as financial advice.

Past backtest performance does not guarantee future results.

---

## Author

**Student Research Project — Sains/Manajemen**

Project:

**Market Structure Trend Following EA**

Platform:

**MetaTrader 5 / MQL5**

Reference:

**René Balke – Fx Bot Trading / BM Trading**

Main Reference Video:

**Copy My Prompts: Claude AI Codes a 5-Year Profitable MetaTrader 5 EA (Step-by-Step)**

https://www.youtube.com/watch?v=mGG0nu8A9FU
