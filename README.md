# Advent of code

My participation to advent of code 2024.

Did it in zig, trying to be as memory efficient and fast as possible.

## Benchmark

Done with 1000 epoch on a AMD Ryzen 7 7800X3D with a Samsung SSD 980 PRO 2TB (up to 7,000/5,100MB/s for read/write speed) on one thread.

Can be run with `zig run -O ReleaseFast benchmark.zig`

|-----|------|-------------------|----------|----------|
| Day | Part | Mean (μs)         | Min (μs) | Max (μs) |
|-----|------|-------------------|----------|----------|
| 1   | 1    |      +29 ± 2.24   |      +28 |      +76 |
| 1   | 2    |      +24 ± 2.00   |      +24 |      +58 |
| 2   | 1    |      +42 ± 5.57   |      +35 |     +177 |
| 2   | 2    |     +318 ± 17.69  |     +298 |     +521 |
| 3   | 1    |      +25 ± 4.69   |      +21 |     +161 |
| 3   | 2    |      +18 ± 1.00   |      +16 |      +31 |
| 4   | 1    |     +223 ± 7.48   |     +217 |     +331 |
| 4   | 2    |     +222 ± 13.00  |     +217 |     +417 |
| 5   | 1    |     +157 ± 10.00  |     +150 |     +290 |
| 5   | 2    |     +158 ± 10.72  |     +151 |     +273 |
| 6   | 1    |      +38 ± 6.00   |      +36 |     +118 |
| 6   | 2    |     Too long ~60s |        0 |        0 |
| 7   | 1    |     +203 ± 24.96  |     +190 |     +634 |
| 6   | 2    |    Too long ~0.2s |        0 |        0 |
| Total |    |    +1457 ± 105.35 |    +1383 |    +3087 |
