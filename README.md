# Advent of code

My participation to advent of code 2024.

Did it in zig, trying to be as memory efficient and fast as possible.

## Benchmark

Done with 1000 epoch on a AMD Ryzen 7 7800X3D with a Samsung SSD 980 PRO 2TB (up to 7,000/5,100MB/s for read/write speed) on one thread.

Can be run with `zig run -O ReleaseFast benchmark.zig`

| Day | Part | Mean (μs)         | Min (μs) | Max (μs) |
|-----|------|-------------------|----------|----------|
| 1   | 1    |      +23 ± 2.24   |      +23 |      +68 |
| 1   | 2    |      +24 ± 4.24   |      +23 |      +86 |
| 2   | 1    |      +36 ± 5.29   |      +32 |      +88 |
| 2   | 2    |     +287 ± 42.28  |     +245 |     +550 |
| 3   | 1    |      +24 ± 2.45   |      +20 |      +41 |
| 3   | 2    |      +21 ± 3.74   |      +17 |      +42 |
| 4   | 1    |     +213 ± 15.75  |     +202 |     +300 |
| 4   | 2    |     +212 ± 13.78  |     +202 |     +340 |
| 5   | 1    |     +160 ± 30.46  |     +120 |     +479 |
| 5   | 2    |     +160 ± 27.29  |     +118 |     +366 |
| 6   | 1    |      +31 ± 3.87   |      +28 |     +128 |
| 6   | 2    |     Too long ~60s |        0 |        0 |
| 7   | 1    |     +191 ± 33.14  |     +156 |     +340 |
| 7   | 2    |    Too long ~0.2s |        0 |        0 |
| 8   | 1    |     +527 ± 69.48  |     +481 |     +896 |
| 8   | 2    |     +803 ± 92.79  |     +736 |    +1328 |
| Total |    |    +2712 ± 346.82 |    +2403 |    +5052 |
