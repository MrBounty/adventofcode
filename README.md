# Advent of code

My participation to advent of code 2024.

Did it in zig, trying to be as memory efficient and fast as possible.

## Benchmark

Can be run with `zig run -O ReleaseFast benchmark.zig`

| Day | Part | Mean (μs)         | Min (μs) | Max (μs) |
|-----|------|-------------------|----------|----------|
| 1   | 1    |      +29 ± 3.00   |      +28 |      +78 |
| 1   | 2    |      +24 ± 2.65   |      +24 |      +56 |
| 2   | 1    |      +43 ± 8.37   |      +37 |     +241 |
| 2   | 2    |     +328 ± 33.84  |     +298 |     +728 |
| 3   | 1    |      +24 ± 6.24   |      +20 |     +170 |
| 3   | 2    |      +23 ± 1.73   |      +20 |      +58 |
| 4   | 2    |     +229 ± 26.15  |     +214 |     +417 |
| 4   | 2    |     +232 ± 26.13  |     +213 |     +337 |
| Total|      |     +932 ± 108.11 |     +854 |    +2085 |
