const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const vec2 = @Vector(2, usize);

// So I need to find out ax + by = c
// With x and y the number of time I click on a and b respectivly
// a and b as how much I advance per click
// And c as total
// And I have 2 equation, one for prize position x and one for y
// Which you can easely do, for float, not int =(
// So how do I approach this ?
// 1. Brute force: I can do all combinaison of x and y. For like 200 max click. 320 prize, 200 * 200 * 320 = 12_800_000
// 2. Pretty sure I can do something with a modulo, because the end pos can only be reach by few combinaison

const State = enum {
    ReadButtonA,
    ReadButtonB,
    ReadPrize,
    ReadJump,
};

pub fn main() !void {
    var iter = std.mem.splitAny(u8, input, "\n");
    var state = State.ReadButtonA;
    var buttonA: vec2 = undefined;
    var buttonB: vec2 = undefined;
    var prize: vec2 = undefined;
    var total: usize = 0;

    while (iter.next()) |line| switch (state) {
        .ReadButtonA => {
            var iterLine = std.mem.splitAny(u8, line, " ");
            _ = iterLine.next(); // Skip Button
            _ = iterLine.next(); // Skip A
            const buf = iterLine.next().?;
            buttonA[0] = try std.fmt.parseInt(usize, buf[2 .. buf.len - 1], 10);
            buttonA[1] = try std.fmt.parseInt(usize, iterLine.next().?[2..], 10);
            state = .ReadButtonB;
        },
        .ReadButtonB => {
            var iterLine = std.mem.splitAny(u8, line, " ");
            _ = iterLine.next(); // Skip Button
            _ = iterLine.next(); // Skip B
            const buf = iterLine.next().?;
            buttonB[0] = try std.fmt.parseInt(usize, buf[2 .. buf.len - 1], 10);
            buttonB[1] = try std.fmt.parseInt(usize, iterLine.next().?[2..], 10);
            state = .ReadPrize;
        },
        .ReadPrize => {
            var iterLine = std.mem.splitAny(u8, line, " ");
            _ = iterLine.next(); // Skip Price
            const buf = iterLine.next().?;
            prize[0] = try std.fmt.parseInt(usize, buf[2 .. buf.len - 1], 10);
            prize[1] = try std.fmt.parseInt(usize, iterLine.next().?[2..], 10);
            state = .ReadJump;
        },
        .ReadJump => {
            state = .ReadButtonA;
            const result = bruteforce(buttonA, buttonB, prize, vec2{ 0, 100 });
            if (result.cost != 99999) total += result.cost;
        },
    };

    try std.testing.expectEqual(33921, total);
}

const Result = struct {
    clickA: usize = 0,
    clickB: usize = 0,
    cost: usize = 999999,
};

fn bruteforce(buttonA: vec2, buttonB: vec2, prize: vec2, range: vec2) Result {
    var minA: usize = 99999;
    var minB: usize = 99999;
    var min_cost: usize = 99999;
    for (range[0]..range[1]) |clickA| for (range[0]..range[1]) |clickB| {
        const end_pos = buttonA * @as(vec2, @splat(clickA)) + buttonB * @as(vec2, @splat(clickB));
        if (!@reduce(.And, end_pos == prize)) continue;
        const cost = clickA * 3 + clickB;
        if (cost < min_cost) {
            minA = clickA;
            minB = clickB;
            min_cost = cost;
        }
    };
    return Result{ .clickA = minA, .clickB = minB, .cost = min_cost };
}
