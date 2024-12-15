const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAPW = 50 * 2;
const MAPH = 50;

const Cell = enum { Empty, BoxL, BoxR, Wall, Robot };
const Direction = enum { Top, Bot, Left, Right };

const Position = struct { x: usize, y: usize };

pub fn main() !void {
    var map: [MAPH][MAPW]Cell = undefined;
    var robot_position: Position = undefined;

    for (input[0 .. MAPH * (MAPH + 1)], 0..) |c, i| {
        if (c == '\n') continue;
        const x = @divFloor(i, MAPH + 1);
        const y = (i % (MAPH + 1)) * 2;
        map[x][y] = switch (c) {
            '.' => .Empty,
            '#' => .Wall,
            'O' => .BoxL,
            '@' => .Robot,
            else => unreachable,
        };
        map[x][y + 1] = switch (c) {
            '.', '@' => .Empty,
            '#' => .Wall,
            'O' => .BoxR,
            else => unreachable,
        };
        if (c == '@') robot_position = Position{ .x = x, .y = y };
    }

    for (input[MAPH * (MAPH + 1) ..]) |c| switch (c) {
        '>' => next(&map, &robot_position, .Right),
        '<' => next(&map, &robot_position, .Left),
        '^' => next(&map, &robot_position, .Top),
        'v' => next(&map, &robot_position, .Bot),
        else => continue,
    };

    try std.testing.expectEqual(1521952, calculateSumPosition(map));
}

// The copy paste suck but if I want to use -1 to do dx dy, I need to use something else than usize and it fuck up the indexing
fn next(map: *[MAPH][MAPW]Cell, robot_position: *Position, direction: Direction) void {
    const x = robot_position.x;
    const y = robot_position.y;

    switch (direction) {
        .Left => switch (map[x][y - 1]) {
            .Empty => {
                map[x][y] = .Empty;
                map[x][y - 1] = .Robot;
                robot_position.*.y -= 1;
            },
            .Wall => {},
            .BoxR, .BoxL => if (moveLeftRight(map, robot_position.*, direction)) {
                map[x][y - 1] = .Robot;
                map[x][y] = .Empty;
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
            .BoxR, .BoxL => if (moveLeftRight(map, robot_position.*, direction)) {
                map[x][y + 1] = .Robot;
                map[x][y] = .Empty;
                robot_position.*.y += 1;
            },
            else => unreachable,
        },
        .Top => switch (map[x - 1][y]) {
            .Empty => {
                map[x][y] = .Empty;
                map[x - 1][y] = .Robot;
                robot_position.*.x -= 1;
            },
            .Wall => {},
            .BoxL, .BoxR => if (moveTopBot(map, robot_position.*, direction)) {
                map[x - 1][y] = .Robot;
                map[x][y] = .Empty;
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
            .BoxL, .BoxR => if (moveTopBot(map, robot_position.*, direction)) {
                map[x + 1][y] = .Robot;
                map[x][y] = .Empty;
                robot_position.*.x += 1;
            },
            else => unreachable,
        },
    }
}

fn moveLeftRight(map: *[MAPH][MAPW]Cell, start: Position, direction: Direction) bool {
    if (direction == .Top or direction == .Bot) @panic("Nope");

    var y = start.y;
    var is_right = direction == .Right;
    if (direction == .Left) y -= 1;
    if (direction == .Right) y += 1;
    while (y != 0 and y != MAPW - 1) : ({
        if (direction == .Left) y -= 1;
        if (direction == .Right) y += 1;
    }) {
        switch (map[start.x][y]) {
            .Empty => {
                while (y != start.y) : ({
                    if (direction == .Left) y += 1;
                    if (direction == .Right) y -= 1;
                    is_right = !is_right;
                }) {
                    map.*[start.x][y] = if (is_right) .BoxR else .BoxL;
                }
                return true;
            },
            .BoxR, .BoxL => continue,
            .Wall => return false,
            .Robot => unreachable,
        }
    }
    return false;
}

fn canMoveTopBot(map: [MAPH][MAPW]Cell, start: Position, direction: Direction) bool {
    if (direction == .Right or direction == .Left) @panic("Nope");

    var x = start.x;
    if (direction == .Top) x -= 1;
    if (direction == .Bot) x += 1;

    switch (map[x][start.y]) {
        .Empty => return true,
        .BoxR => return canMoveTopBot(map, Position{ .x = x, .y = start.y }, direction) and canMoveTopBot(map, Position{ .x = x, .y = start.y - 1 }, direction),
        .BoxL => return canMoveTopBot(map, Position{ .x = x, .y = start.y }, direction) and canMoveTopBot(map, Position{ .x = x, .y = start.y + 1 }, direction),
        .Wall => return false,
        .Robot => unreachable,
    }
}

fn moveTopBot(map: *[MAPH][MAPW]Cell, start: Position, direction: Direction) bool {
    if (direction == .Right or direction == .Left) @panic("Nope");

    if (!canMoveTopBot(map.*, start, direction)) return false;

    const x = if (direction == .Top) start.x - 1 else start.x + 1;
    switch (map[x][start.y]) {
        .Empty => return true,
        .BoxR => if (moveTopBot(map, Position{ .x = x, .y = start.y }, direction) and moveTopBot(map, Position{ .x = x, .y = start.y - 1 }, direction)) {
            map.*[if (direction == .Top) x - 1 else x + 1][start.y] = .BoxR;
            map.*[if (direction == .Top) x - 1 else x + 1][start.y - 1] = .BoxL;
            map.*[x][start.y] = .Empty;
            map.*[x][start.y - 1] = .Empty;
            return true;
        } else return false,
        .BoxL => if (moveTopBot(map, Position{ .x = x, .y = start.y }, direction) and moveTopBot(map, Position{ .x = x, .y = start.y + 1 }, direction)) {
            map.*[if (direction == .Top) x - 1 else x + 1][start.y] = .BoxL;
            map.*[if (direction == .Top) x - 1 else x + 1][start.y + 1] = .BoxR;
            map.*[x][start.y] = .Empty;
            map.*[x][start.y + 1] = .Empty;
            return true;
        } else return false,
        .Wall => return false,
        .Robot => unreachable,
    }
}

fn calculateSumPosition(map: [MAPH][MAPW]Cell) usize {
    var total: usize = 0;
    for (map, 0..) |row, x| for (row, 0..) |cell, y| switch (cell) {
        .BoxL => total += x * 100 + y,
        else => {},
    };
    return total;
}
