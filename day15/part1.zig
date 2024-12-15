const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAP_SIZE = 50;

const Cell = enum { Empty, Box, Wall, Robot };
const Direction = enum { Top, Bot, Left, Right };

const Position = struct { x: usize, y: usize };

pub fn main() !void {
    var map: [MAP_SIZE][MAP_SIZE]Cell = undefined;
    var robot_position: Position = undefined;

    for (input[0 .. MAP_SIZE * (MAP_SIZE + 1)], 0..) |c, i| {
        if (c == '\n') continue;
        map[@divFloor(i, MAP_SIZE + 1)][i % (MAP_SIZE + 1)] = switch (c) {
            '.' => .Empty,
            '#' => .Wall,
            'O' => .Box,
            '@' => .Robot,
            else => unreachable,
        };
        if (c == '@') robot_position = Position{ .x = @divFloor(i, MAP_SIZE + 1), .y = i % (MAP_SIZE + 1) };
    }

    for (input[MAP_SIZE * (MAP_SIZE + 1) ..]) |c| switch (c) {
        '>' => next(&map, &robot_position, .Right),
        '<' => next(&map, &robot_position, .Left),
        '^' => next(&map, &robot_position, .Top),
        'v' => next(&map, &robot_position, .Bot),
        else => {},
    };

    try std.testing.expectEqual(1487337, calculateSumPosition(map));
}

// The copy paste suck but if I want to use -1 to do dx dy, I need to use something else than usize and it fuck up the indexing
fn next(map: *[MAP_SIZE][MAP_SIZE]Cell, robot_position: *Position, direction: Direction) void {
    const x = robot_position.x;
    const y = robot_position.y;

    switch (direction) {
        .Top => switch (map[x - 1][y]) {
            .Empty => {
                map[x][y] = .Empty;
                map[x - 1][y] = .Robot;
                robot_position.*.x -= 1;
            },
            .Wall => {},
            .Box => if (detectFirstEmpty(map.*, robot_position.*, direction)) |first_empty| {
                map[first_empty.x][first_empty.y] = .Box;
                map[x][y] = .Empty;
                map[x - 1][y] = .Robot;
                robot_position.*.x -= 1;
            },
            else => unreachable,
        },
        .Bot => switch (map[x + 1][y]) {
            .Empty => {
                map[x][y] = .Empty;
                map[x + 1][y] = .Robot;
                robot_position.*.x += 1;
            },
            .Wall => {},
            .Box => if (detectFirstEmpty(map.*, robot_position.*, direction)) |first_empty| {
                map[first_empty.x][first_empty.y] = .Box;
                map[x][y] = .Empty;
                map[x + 1][y] = .Robot;
                robot_position.*.x += 1;
            },
            else => unreachable,
        },
        .Left => switch (map[x][y - 1]) {
            .Empty => {
                map[x][y] = .Empty;
                map[x][y - 1] = .Robot;
                robot_position.*.y -= 1;
            },
            .Wall => {},
            .Box => if (detectFirstEmpty(map.*, robot_position.*, direction)) |first_empty| {
                map[first_empty.x][first_empty.y] = .Box;
                map[x][y] = .Empty;
                map[x][y - 1] = .Robot;
                robot_position.*.y -= 1;
            },
            else => unreachable,
        },
        .Right => switch (map[x][y + 1]) {
            .Empty => {
                map[x][y] = .Empty;
                map[x][y + 1] = .Robot;
                robot_position.*.y += 1;
            },
            .Wall => {},
            .Box => if (detectFirstEmpty(map.*, robot_position.*, direction)) |first_empty| {
                map[first_empty.x][first_empty.y] = .Box;
                map[x][y] = .Empty;
                map[x][y + 1] = .Robot;
                robot_position.*.y += 1;
            },
            else => unreachable,
        },
    }
}

fn detectFirstEmpty(map: [MAP_SIZE][MAP_SIZE]Cell, start: Position, direction: Direction) ?Position {
    var x = start.x;
    var y = start.y;
    if (direction == .Top) x -= 1;
    if (direction == .Bot) x += 1;
    if (direction == .Left) y -= 1;
    if (direction == .Right) y += 1;
    while (x != 0 and x != MAP_SIZE - 1 and y != 0 and y != MAP_SIZE - 1) : ({
        if (direction == .Top) x -= 1;
        if (direction == .Bot) x += 1;
        if (direction == .Left) y -= 1;
        if (direction == .Right) y += 1;
    }) {
        switch (map[x][y]) {
            .Empty => return Position{ .x = x, .y = y },
            .Box => continue,
            .Wall => return null,
            .Robot => unreachable,
        }
    }
    return null;
}

fn calculateSumPosition(map: [MAP_SIZE][MAP_SIZE]Cell) usize {
    var total: usize = 0;
    for (map, 0..) |row, x| for (row, 0..) |cell, y| switch (cell) {
        .Box => total += x * 100 + y,
        else => {},
    };
    return total;
}
