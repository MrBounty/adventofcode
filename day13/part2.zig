const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const Usize = std.atomic.Value(usize);
const vec2 = @Vector(2, usize);

// I am not proud of this solution, it take like 6h to run on 16 thread :/
// I am sure I can change the bruteForce function to use modulo to reduce the number of clickA
// But it was late, I was tired so I juste started this version and the next morning it was complete soooo
// I will no go futher, I am already 2 days behind :/

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
    var total = Usize.init(0);
    var finished = Usize.init(0);
    var to_wait: usize = 0;

    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var thread_arena = std.heap.ThreadSafeAllocator{
        .child_allocator = allocator,
    };

    var thread_pool: std.Thread.Pool = undefined;
    thread_pool.init(std.Thread.Pool.Options{
        .allocator = thread_arena.allocator(),
        .n_jobs = 16,
    }) catch @panic("=(");

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
            prize[0] = try std.fmt.parseInt(usize, buf[2 .. buf.len - 1], 10) + 10000000000000;
            prize[1] = try std.fmt.parseInt(usize, iterLine.next().?[2..], 10) + 10000000000000;
            state = .ReadJump;
        },
        .ReadJump => {
            state = .ReadButtonA;
            try thread_pool.spawn(bruteforce, .{ buttonA, buttonB, prize, &total, &finished, to_wait });
            to_wait += 1;
        },
    };

    while (to_wait > finished.load(.monotonic)) {
        std.time.sleep(1000000);
        printProgressOverall(finished.load(.monotonic), to_wait);
    }

    print("Total: {d}\n", .{total.load(.monotonic)});
}

const Result = struct {
    clickA: usize = 0,
    clickB: usize = 0,
    cost: usize = 999999,
};

fn bruteforce(buttonA: vec2, buttonB: vec2, prize: vec2, total: *Usize, finished: *Usize, id: usize) void {
    var min_cost: usize = std.math.maxInt(usize);
    const max_clickA = @min(@divFloor(prize[0], buttonA[0]), @divFloor(prize[1], buttonA[1])) + 10;

    var clickA: usize = 0;
    while (clickA <= max_clickA) : (clickA += 1) {
        if (clickA % 1000000000 == 0) printProgress(clickA, max_clickA, id);

        const remaining = prize - buttonA * @as(vec2, @splat(clickA));
        if (@reduce(.Or, remaining < @as(vec2, @splat(0)))) continue;

        const clickB = @divFloor(remaining, buttonB);
        if (clickB[0] != clickB[1]) continue;

        if (@reduce(.Or, remaining % buttonB != @as(vec2, @splat(0)))) continue;

        const cost = clickA * 3 + clickB[0];
        if (cost < min_cost) min_cost = cost;
    }

    if (min_cost != std.math.maxInt(usize)) {
        _ = total.fetchAdd(min_cost, .monotonic);
    }
    _ = finished.fetchAdd(1, .monotonic);
}

fn printProgress(value: usize, max: usize, id: usize) void {
    print("Thread {d}: {d}% | {d}/{d}\n", .{ id, @divFloor(value * 100, max), value, max });
}

fn printProgressOverall(finished: usize, total: usize) void {
    std.debug.print("Overall: {d}/{d} ({d}%)    \r", .{ finished, total, @divFloor(finished * 100, total) });
}

fn gcd(a: u64, b: u64) u64 {
    if (b == 0) {
        return a;
    } else {
        return gcd(b, a % b);
    }
}

fn isPossible(a: u64, b: u64, c: u64) bool {
    return c % gcd(a, b) == 0;
}
