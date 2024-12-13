const std = @import("std");

pub fn main() !void {
    var map = std.AutoHashMap(usize, usize).init(std.heap.page_allocator);
    defer map.deinit();

    for ([_]usize{ 890, 0, 1, 935698, 68001, 3441397, 7221, 27 }) |n| try map.put(n, (map.get(n) orelse 0) + 1);

    for (0..75) |_| try step(&map);
    try std.testing.expectEqual(233007586663131, countStone(map));
}

fn step(map: *std.AutoHashMap(usize, usize)) !void {
    var old_map = try map.clone();
    defer old_map.deinit();

    map.clearRetainingCapacity();
    var iter = old_map.iterator();
    while (iter.next()) |entry| {
        if (entry.key_ptr.* == 0) {
            try map.put(1, (map.get(1) orelse 0) + entry.value_ptr.*);
        } else if (countDigit(entry.key_ptr.*) % 2 == 0) {
            const splits = splitDigit(entry.key_ptr.*);
            try map.put(splits[0], (map.get(splits[0]) orelse 0) + entry.value_ptr.*);
            try map.put(splits[1], (map.get(splits[1]) orelse 0) + entry.value_ptr.*);
        } else {
            try map.put(entry.key_ptr.* * 2024, (map.get(entry.key_ptr.* * 2024) orelse 0) + entry.value_ptr.*);
        }
    }
}

fn countDigit(number: usize) usize {
    var n: usize = number;
    var count: usize = 0;
    while (n != 0) : (count += 1) n = @divFloor(n, 10);
    return count;
}

fn splitDigit(number: usize) [2]usize {
    const divider = std.math.pow(usize, 10, (countDigit(number) / 2));
    return [2]usize{ @divFloor(number, divider), number % divider };
}

fn countStone(map: std.AutoHashMap(usize, usize)) usize {
    var total: usize = 0;
    var iter = map.valueIterator();
    while (iter.next()) |entry| total += entry.*;
    return total;
}
