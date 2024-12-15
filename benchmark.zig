const std = @import("std");
const print = std.debug.print;

const d11 = @import("day1/part1.zig");
const d12 = @import("day1/part2.zig");
const d21 = @import("day2/part1.zig");
const d22 = @import("day2/part2.zig");
const d31 = @import("day3/part1.zig");
const d32 = @import("day3/part2.zig");
const d41 = @import("day4/part1.zig");
const d42 = @import("day4/part2.zig");
const d51 = @import("day5/part1.zig");
const d52 = @import("day5/part2.zig");
const d61 = @import("day6/part1.zig");
const d71 = @import("day7/part1.zig");
const d72 = @import("day7/part2.zig");
const d81 = @import("day8/part1.zig");
const d82 = @import("day8/part2.zig");
const d91 = @import("day9/part1.zig");
const d92 = @import("day9/part2.zig");
const d101 = @import("day10/part1.zig");
const d102 = @import("day10/part2.zig");
const d111 = @import("day11/part1.zig");
const d112 = @import("day11/part2.zig");
const d121 = @import("day12/part1.zig");
const d122 = @import("day12/part2.zig");
const d131 = @import("day13/part1.zig");
const d141 = @import("day14/part1.zig");
const d151 = @import("day15/part1.zig");
const d152 = @import("day15/part2.zig");

const NUMBER_OF_RUN = 50;

var total_mean: i64 = 0;
var total_min: i64 = 0;
var total_max: i64 = 0;
var total_std_dev: f64 = 0;

pub fn main() !void {
    separator();
    print("| Day | Part | Mean (μs)         | Min (μs) | Max (μs) |\n", .{});
    separator();
    try benchmark(d11.main, 1, 1);
    try benchmark(d12.main, 1, 2);
    separator();
    try benchmark(d21.main, 2, 1);
    try benchmark(d22.main, 2, 2);
    separator();
    try benchmark(d31.main, 3, 1);
    try benchmark(d32.main, 3, 2);
    separator();
    try benchmark(d42.main, 4, 1);
    try benchmark(d42.main, 4, 2);
    separator();
    try benchmark(d51.main, 5, 1);
    try benchmark(d52.main, 5, 2);
    separator();
    try benchmark(d61.main, 6, 1);
    print("| 6   | 2    |     Too long ~60s |        0 |        0 |\n", .{});
    separator();
    try benchmark(d71.main, 7, 1);
    print("| 7   | 2    |    Too long ~0.2s |        0 |        0 |\n", .{});
    separator();
    try benchmark(d81.main, 8, 1);
    try benchmark(d82.main, 8, 2);
    separator();
    try benchmark(d91.main, 9, 1);
    print("| 9   | 2    |    Too long ~0.6s |        0 |        0 |\n", .{});
    separator();
    try benchmark(d101.main, 10, 1);
    try benchmark(d102.main, 10, 2);
    separator();
    try benchmark(d111.main, 11, 1);
    try benchmark(d112.main, 11, 2);
    separator();
    try benchmark(d121.main, 12, 1);
    try benchmark(d122.main, 12, 2);
    separator();
    try benchmark(d131.main, 13, 1);
    print("| 13  | 2    |    Too long ~6h   |        0 |        0 |\n", .{});
    separator();
    try benchmark(d141.main, 14, 1);
    print("| 14  | 2    |    Need input     |        0 |        0 |\n", .{});
    separator();
    try benchmark(d151.main, 15, 1);
    try benchmark(d152.main, 15, 2);
    separator();
    print("| Total      | {d: >8} ± {d: <6.2} | {d:>8} | {d:>8} |\n", .{ total_mean, total_std_dev, total_min, total_max });
    separator();
}

pub fn benchmark(func: anytype, day: u8, part: u8) !void {
    var time_buff: [NUMBER_OF_RUN]i64 = undefined;

    for (0..NUMBER_OF_RUN) |i| {
        const time_start = std.time.microTimestamp();
        try func();
        time_buff[i] = std.time.microTimestamp() - time_start;
    }

    // Adjusted tabs for better alignment
    print("| {d:<3} | {d:<4} | {d:>8} ± {d:<6.2} | {d:>8} | {d:>8} |\n", .{ day, part, mean(time_buff), std_dev(time_buff), min(time_buff), max(time_buff) });
    total_mean += mean(time_buff);
    total_min += min(time_buff);
    total_max += max(time_buff);
    total_std_dev += std_dev(time_buff);
}

pub fn separator() void {
    print("|-----|------|-------------------|----------|----------|\n", .{});
}

fn min(array: [NUMBER_OF_RUN]i64) i64 {
    var current_min: i64 = 999999999999;
    for (array) |value| {
        if (value < current_min) current_min = value;
    }
    return current_min;
}

fn max(array: [NUMBER_OF_RUN]i64) i64 {
    var current_max: i64 = 0;
    for (array) |value| {
        if (value > current_max) current_max = value;
    }
    return current_max;
}

fn mean(array: [NUMBER_OF_RUN]i64) i64 {
    var total: i64 = 0;
    for (array) |value| {
        total += value;
    }
    return @divFloor(total, NUMBER_OF_RUN);
}

fn variance(array: [NUMBER_OF_RUN]i64) i64 {
    const m = mean(array);
    var square_diff: i64 = 0;
    for (array) |value| {
        square_diff += (value - m) * (value - m);
    }
    return @divFloor(square_diff, NUMBER_OF_RUN);
}

fn std_dev(array: [NUMBER_OF_RUN]i64) f64 {
    const vari = @as(f64, @floatFromInt(variance(array)));

    return @sqrt(vari);
}
