const std = @import("std");
const print = std.debug.print;

const file = @embedFile("input");

pub fn main() !void {
    var left: [1000]i32 = undefined;
    var right: [1000]i32 = undefined;

    var i: u32 = 0;
    var iter = std.mem.split(u8, file, "\n");
    while (iter.next()) |line| {
        if (i == 1000) continue;
        left[i] = try std.fmt.parseInt(i32, line[0..5], 10);
        right[i] = try std.fmt.parseInt(i32, line[8..13], 10);
        i += 1;
    }

    try std.testing.expectEqual(24869388, similarity(left, right));
}

fn distance(left: [1000]i32, right: [1000]i32) u32 {
    var total_distance: u32 = 0;
    for (left, right) |l, r| {
        total_distance += @abs(r - l);
    }
    return total_distance;
}

fn similarity(left: [1000]i32, right: [1000]i32) !i32 {
    // Make a map with value -> occurence
    var buff: [1024 * 100]u8 = undefined;
    var fbuf = std.heap.FixedBufferAllocator.init(&buff);
    const allocator = fbuf.allocator();

    var map = std.AutoHashMap(i32, u8).init(allocator);
    defer map.deinit();

    for (right) |r| {
        if (map.get(r)) |r_count| {
            try map.put(r, r_count + 1);
        } else {
            try map.put(r, 1);
        }
    }

    var total_similarity: i32 = 0;
    for (left) |l| {
        if (map.get(l)) |r_count| total_similarity += l * r_count;
    }
    return total_similarity;
}
