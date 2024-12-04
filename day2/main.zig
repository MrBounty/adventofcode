const std = @import("std");
const print = std.debug.print;

const State = enum { First, Second, Incr, Decr }; // Increase Decrease

var line_buf: [64]u8 = undefined;
var second_buf: [64]u8 = undefined;
var previous: u8 = 0;
var current: u8 = 0;

pub fn main() !void {
    const time_start = std.time.microTimestamp();

    var fbuf = std.heap.FixedBufferAllocator.init(&line_buf);
    const alloc = fbuf.allocator();
    var line = std.ArrayList(u8).initCapacity(alloc, line_buf.len) catch unreachable;

    const file = try std.fs.cwd().openFile("day2/input", .{});
    defer file.close();

    var buf_reader = std.io.bufferedReader(file.reader());
    const reader = buf_reader.reader();

    const writer = line.writer();
    var total_safe: usize = 0;
    while (reader.streamUntilDelimiter(writer, '\n', null)) {
        // Clear the line so we can reuse it.
        defer line.clearRetainingCapacity();

        if (try isSafe(line.items)) {
            total_safe += 1;
            continue;
        }

        var i: u8 = 0;
        var it = std.mem.split(u8, line.items, " ");
        while (it.next()) |_| {
            const new_line = try removeOneIndex(line.items, i);
            if (try isSafe(new_line)) {
                total_safe += 1;
                break;
            }
            i += 1;
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err, // Propagate error
    }

    const time_end = std.time.microTimestamp();
    print("Total time: {d}μs\n", .{time_end - time_start});
    print("Total safe: {d}\n", .{total_safe});
}

fn isSafe(line: []const u8) !bool {
    var state: State = .First;

    var it = std.mem.split(u8, line, " ");
    while (it.next()) |x| {
        defer previous = current;
        current = try std.fmt.parseInt(u8, x, 10);

        if (state != .First and previous == current) return false;
        if (state != .First and ((previous > current and (previous - current) > 3) or (previous < current and (current - previous) > 3))) return false;

        state = switch (state) {
            .First => .Second,
            .Second => if (previous > current) .Decr else .Incr,
            .Decr => if (previous > current) .Decr else return false,
            .Incr => if (previous < current) .Incr else return false,
        };
    }

    return true;
}

fn removeOneIndex(line: []const u8, index: u8) ![]const u8 {
    var fbuf = std.heap.FixedBufferAllocator.init(&second_buf);
    const alloc = fbuf.allocator();
    var new_line = std.ArrayList(u8).initCapacity(alloc, second_buf.len) catch unreachable;
    var writer = new_line.writer();

    var i: u8 = 0;

    var it = std.mem.split(u8, line, " ");
    while (it.next()) |x| {
        if (index != i) try writer.print("{s} ", .{x});
        i += 1;
    }

    _ = new_line.pop();

    return try new_line.toOwnedSlice();
}

test "Is safe" {
    try std.testing.expect(try isSafe("1 2 3"));
    try std.testing.expect(try isSafe("1 2 3 4 5 6 7 8 9"));
    try std.testing.expect(try isSafe("243 241 239"));
    try std.testing.expect(!try isSafe("1 2 3 8"));
    try std.testing.expect(!try isSafe("1 2 3 2 1"));
    try std.testing.expect(!try isSafe("1 2 3 3 1"));
    try std.testing.expect(!try isSafe("1 1 3 3 1"));
}
