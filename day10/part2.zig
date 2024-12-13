const std = @import("std");
const input = @embedFile("input");
const MAP_SIZE = 60;

pub fn main() !void {
    var map = [_][MAP_SIZE + 2]u8{[_]u8{0} ** (MAP_SIZE + 2)} ** (MAP_SIZE + 2);

    for (input, 0..) |c, i| {
        if (c == '\n') continue;
        map[@divFloor(i, MAP_SIZE + 1) + 1][i % (MAP_SIZE + 1) + 1] = c - '0';
    }

    var total: usize = 0;
    for (1..MAP_SIZE + 1) |x| for (1..MAP_SIZE + 1) |y| if (map[x][y] == 0) try step(map, x, y, &total);

    try std.testing.expectEqual(1651, total);
}

fn step(map: [MAP_SIZE + 2][MAP_SIZE + 2]u8, x: usize, y: usize, total: *usize) !void {
    const height = map[x][y];
    if (height == 9) total.* += 1;
    if (map[x - 1][y] == (height + 1)) try step(map, x - 1, y, total); // Up
    if (map[x + 1][y] == (height + 1)) try step(map, x + 1, y, total); // Down
    if (map[x][y - 1] == (height + 1)) try step(map, x, y - 1, total); // Left
    if (map[x][y + 1] == (height + 1)) try step(map, x, y + 1, total); // Right
}
