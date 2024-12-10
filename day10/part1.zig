const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAP_SIZE = 60;

pub fn main() !void {
    var map: [MAP_SIZE + 2][MAP_SIZE + 2]u8 = undefined;

    for (0..MAP_SIZE + 2) |x| for (0..MAP_SIZE + 2) |y| {
        map[x][y] = 0;
    };

    for (input, 0..) |c, i| {
        if (c == '\n') continue;
        map[@divFloor(i, MAP_SIZE + 1) + 1][i % (MAP_SIZE + 1) + 1] = c - '0';
    }

    var total: usize = 0;
    var founded = std.AutoHashMap([2]usize, void).init(std.heap.page_allocator);
    defer founded.deinit();
    for (1..MAP_SIZE + 1) |x| for (1..MAP_SIZE + 1) |y| if (map[x][y] == 0) {
        founded.clearRetainingCapacity();
        try step(map, x, y, &total, &founded);
    };

    try std.testing.expectEqual(744, total);
}

fn step(map: [MAP_SIZE + 2][MAP_SIZE + 2]u8, x: usize, y: usize, total: *usize, founded: *std.AutoHashMap([2]usize, void)) !void {
    const height = map[x][y];
    if (height == 9 and !founded.contains([2]usize{ x, y })) {
        total.* += 1;
        try founded.put([2]usize{ x, y }, {});
    }
    if (map[x - 1][y] == (height + 1)) try step(map, x - 1, y, total, founded); // Up
    if (map[x + 1][y] == (height + 1)) try step(map, x + 1, y, total, founded); // Down
    if (map[x][y - 1] == (height + 1)) try step(map, x, y - 1, total, founded); // Left
    if (map[x][y + 1] == (height + 1)) try step(map, x, y + 1, total, founded); // Right
}
