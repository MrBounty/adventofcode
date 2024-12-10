# Advent of code

My participation to advent of code 2024.

Did it in zig, trying to be as memory efficient and fast as possible.

## Benchmark

Done with 1000 epoch on a AMD Ryzen 7 7800X3D with a Samsung SSD 980 PRO 2TB (up to 7,000/5,100MB/s for read/write speed) on one thread.

Can be run with `zig run -O ReleaseFast benchmark.zig`

| Day | Part | Mean (μs)         | Min (μs) | Max (μs) |
|-----|------|-------------------|----------|----------|
| 1   | 1    |      +23 ± 3.74   |      +22 |      +92 |
| 1   | 2    |      +23 ± 2.00   |      +22 |      +53 |
| 2   | 1    |      +34 ± 2.45   |      +32 |      +83 |
| 2   | 2    |     +261 ± 36.08  |     +239 |     +764 |
| 3   | 1    |      +19 ± 1.41   |      +18 |      +38 |
| 3   | 2    |      +18 ± 1.00   |      +17 |      +44 |
| 4   | 1    |     +214 ± 29.29  |     +202 |     +536 |
| 4   | 2    |     +215 ± 29.09  |     +201 |     +558 |
| 5   | 1    |     +139 ± 36.43  |     +117 |     +540 |
| 5   | 2    |     +153 ± 44.35  |     +116 |     +475 |
| 6   | 1    |      +31 ± 2.83   |      +28 |     +101 |
| 6   | 2    |     Too long ~60s |        0 |        0 |
| 7   | 1    |     +182 ± 18.06  |     +157 |     +439 |
| 7   | 2    |    Too long ~0.2s |        0 |        0 |
| 8   | 1    |     +540 ± 53.40  |     +506 |     +895 |
| 8   | 2    |     +828 ± 81.50  |     +769 |    +1333 |
| 9   | 1    |    +1770 ± 215.91 |    +1389 |    +5250 |
| 9   | 2    |    Too long ~0.6s |        0 |        0 |
| 10  | 1    |      +38 ± 5.66   |      +36 |     +160 |
| 10  | 2    |      +27 ± 2.45   |      +27 |      +64 |
| Total|     |    +4515 ± 565.65 |    +3898 |   +11425 |
