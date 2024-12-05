# Advent of code

My participation to advent of code 2024.

Did it in zig, trying to be as memory efficient and fast as possible.

## Benchmark

Done with 1000 epoch on a AMD Ryzen 7 7800X3D with a Samsung SSD 980 PRO 2TB (up to 7,000/5,100MB/s for read/write speed) on one thread.

Can be run with `zig run -O ReleaseFast benchmark.zig`

| Day | Part | Mean (μs)         | Min (μs) | Max (μs) |
|-----|------|-------------------|----------|----------|
| 1   | 1    |      +29 ± 3.74   |      +28 |      +99 |
| 1   | 2    |      +26 ± 6.78   |      +24 |     +136 |
| 2   | 1    |      +39 ± 6.00   |      +37 |     +179 |
| 2   | 2    |     +314 ± 17.64  |     +291 |     +446 |
| 3   | 1    |      +21 ± 5.20   |      +20 |     +163 |
| 3   | 2    |      +19 ± 2.24   |      +18 |      +43 |
| 4   | 1    |     +225 ± 16.31  |     +217 |     +347 |
| 4   | 2    |     +220 ± 7.87   |     +216 |     +311 |
| 5   | 1    |     +166 ± 24.29  |     +148 |     +429 |
| 5   | 2    |     +228 ± 69.64  |     +173 |     +661 |
| Total|      |    +1287 ± 159.71 |    +1172 |    +2814 |
