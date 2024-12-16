const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAP_SIZE = 141;

const Direction = enum { Top, Bottom, Left, Right };

const Cell = struct {
    is: enum { Wall, Empty, End },
    visited_by: struct {
        top: bool = false,
        bottom: bool = false,
        left: bool = false,
        right: bool = false,
    } = .{},
    just_visited_by: struct {
        top: bool = false,
        bottom: bool = false,
        left: bool = false,
        right: bool = false,
    } = .{},

    fn visit(self: *Cell, direction: Direction) void {
        if (direction == .Top) self.just_visited_by.top = true;
        if (direction == .Left) self.just_visited_by.left = true;
        if (direction == .Right) self.just_visited_by.right = true;
        if (direction == .Bottom) self.just_visited_by.bottom = true;
    }

    fn update(self: *Cell) void {
        if (self.just_visited_by.top) {
            self.just_visited_by.top = false;
            self.visited_by.top = true;
        }
        if (self.just_visited_by.bottom) {
            self.just_visited_by.bottom = false;
            self.visited_by.bottom = true;
        }
        if (self.just_visited_by.right) {
            self.just_visited_by.right = false;
            self.visited_by.right = true;
        }
        if (self.just_visited_by.left) {
            self.just_visited_by.left = false;
            self.visited_by.left = true;
        }
    }

    fn visited(self: *Cell, direction: Direction) bool {
        return switch (direction) {
            .Top => self.visited_by.top,
            .Bottom => self.visited_by.bottom,
            .Right => self.visited_by.right,
            .Left => self.visited_by.left,
        };
    }
};

const Position = struct {
    x: usize,
    y: usize,
};

const Path = struct {
    position: Position,
    direction: Direction,
    number_of_turn_done: usize, // I could just save the cost total, I dont really need those 2 value
    number_of_tile_walked: usize,
    visited: [10000]Position = undefined,
    visited_len: usize = 0,
};

const Map = struct {
    map: [MAP_SIZE][MAP_SIZE]Cell,
    paths: *std.ArrayList(Path),
    minimum: ?usize = null,

    fn init(allocator: std.mem.Allocator) !Map {
        const list = try allocator.create(std.ArrayList(Path));
        list.* = std.ArrayList(Path).init(allocator);

        var map: [MAP_SIZE][MAP_SIZE]Cell = undefined;
        for (input[0 .. MAP_SIZE * (MAP_SIZE + 1)], 0..) |c, i| {
            if (c == '\n') continue;
            map[@divFloor(i, MAP_SIZE + 1)][i % (MAP_SIZE + 1)] = switch (c) {
                '.', 'S' => Cell{ .is = .Empty },
                '#' => Cell{ .is = .Wall },
                'E' => Cell{ .is = .End },
                else => unreachable,
            };
            if (c == 'S') try list.append(Path{
                .direction = .Right,
                .position = Position{ .x = @divFloor(i, MAP_SIZE + 1), .y = i % (MAP_SIZE + 1) - 1 },
                .number_of_turn_done = 0,
                .number_of_tile_walked = 0,
            });
        }

        return Map{ .paths = list, .map = map };
    }

    // Each step is a turn of a path. So if a path need to turn to continue, it add itself to self.paths to be continue in the next step
    // If it can continue walking it just continue walking as it cost nothing
    fn solve(self: *Map, allocator: std.mem.Allocator) !usize {
        var minimum: ?usize = null;
        var visited = std.AutoHashMap(Position, void).init(allocator);

        while (minimum == null and self.paths.items.len != 0) {
            const paths = try allocator.alloc(Path, self.paths.items.len);
            defer allocator.free(paths);
            for (self.paths.items, 0..) |path, i| paths[i] = path;
            self.paths.clearRetainingCapacity();
            for (0..MAP_SIZE) |x| for (0..MAP_SIZE) |y| self.map[x][y].update();

            for (paths) |*path| blk: while (true) {
                var x: usize = path.position.x;
                if (path.direction == .Top) x -= 1 else if (path.direction == .Bottom) x += 1;
                var y: usize = path.position.y;
                if (path.direction == .Left) y -= 1 else if (path.direction == .Right) y += 1;

                if (self.map[x][y].is == .Wall) break :blk;
                path.visited_len += 1;
                if (self.map[x][y].visited(path.direction)) break :blk;
                self.map[x][y].visit(path.direction);
                path.visited[path.visited_len] = Position{ .x = x, .y = y };
                path.number_of_tile_walked += 1;
                if (self.map[x][y].is == .End) {
                    if (minimum == null or path.number_of_turn_done * 1000 + path.number_of_tile_walked < minimum.?) {
                        minimum = path.number_of_turn_done * 1000 + path.number_of_tile_walked;
                    }
                    if (path.number_of_turn_done * 1000 + path.number_of_tile_walked == minimum.?) {
                        for (path.visited[0..path.visited_len]) |pos| try visited.put(pos, {});
                    }
                    break :blk;
                }

                path.position.x = x;
                path.position.y = y;
                try self.checkSurroundingAndCreatePath(path.*);
            };
        }
        return visited.count();
    }

    fn checkSurroundingAndCreatePath(self: *Map, path: Path) !void {
        const x = path.position.x;
        const y = path.position.y;
        switch (path.direction) {
            .Right, .Left => {
                if (self.map[x - 1][y].is == .Empty and !self.map[x - 1][y].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Top,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
                    .visited = path.visited,
                    .visited_len = path.visited_len,
                });
                if (self.map[x + 1][y].is == .Empty and !self.map[x + 1][y].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Bottom,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
                    .visited = path.visited,
                    .visited_len = path.visited_len,
                });
            }, //
            .Top, .Bottom => {
                if (self.map[x][y - 1].is == .Empty and !self.map[x][y - 1].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Left,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
                    .visited = path.visited,
                    .visited_len = path.visited_len,
                });
                if (self.map[x][y + 1].is == .Empty and !self.map[x][y + 1].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Right,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
                    .visited = path.visited,
                    .visited_len = path.visited_len,
                });
            },
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var map = try Map.init(allocator);
    const total = try map.solve(allocator);
    try std.testing.expectEqual(565, total);
}
