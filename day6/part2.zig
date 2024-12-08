const std = @import("std");
const print = std.debug.print;
const file = @embedFile("input");

const VisitedBy = struct { up: bool = false, down: bool = false, right: bool = false, left: bool = false };

const Point = struct {
    type_: enum { End, Obstacle, Empty } = .End,
    visited_by: VisitedBy = .{},

    fn point2Orientation(self: Point) Orientation {
        return switch (self) {
            .VisitedUp => .UP,
            .VisitedRight => .RIGHT,
            .VisitedDown => .DOWN,
            .VisitedLeft => .LEFT,
            else => unreachable,
        };
    }

    fn visitedAny(self: Point) bool {
        return self.visited_by.up or self.visited_by.down or self.visited_by.left or self.visited_by.right;
    }
};

const Orientation = enum { UP, DOWN, LEFT, RIGHT };

const Position = struct {
    x: i16,
    y: i16,
};

const Gard = struct {
    position: Position = undefined,
    orientation: Orientation = .UP,

    fn move(self: *Gard) void {
        self.position.x += if (self.orientation == .UP) -1 else if (self.orientation == .DOWN) 1 else 0;
        self.position.y += if (self.orientation == .LEFT) -1 else if (self.orientation == .RIGHT) 1 else 0;
    }

    fn inFront(self: Gard) Position {
        var x = self.position.x;
        x += if (self.orientation == .UP) -1 else if (self.orientation == .DOWN) 1 else 0;
        var y = self.position.y;
        y += if (self.orientation == .LEFT) -1 else if (self.orientation == .RIGHT) 1 else 0;
        return Position{
            .x = x,
            .y = y,
        };
    }

    fn rotate(self: *Gard) void {
        self.orientation = switch (self.orientation) {
            .UP => .RIGHT,
            .RIGHT => .DOWN,
            .DOWN => .LEFT,
            .LEFT => .UP,
        };
    }
};

const Map = struct {
    buff: [132][132]Point = undefined,
    gard: Gard,

    allocator: std.mem.Allocator,
    founded_loop: *std.AutoHashMap(Position, void),

    fn init(allocator: std.mem.Allocator) !Map {
        const map = try allocator.create(std.AutoHashMap(Position, void));
        map.* = std.AutoHashMap(Position, void).init(allocator);
        return Map{
            .allocator = allocator,
            .gard = Gard{},
            .founded_loop = map,
        };
    }

    fn deinit(self: *Map) void {
        self.founded_loop.deinit();
        self.allocator.destroy(self.founded_loop);
    }

    fn isNextPositionVisited(self: Map) bool {
        var gard_ = self.gard;
        for (0..4) |_| {
            if (self.get(gard_.inFront()).?.type_ == .Obstacle) {
                gard_.rotate();
                continue;
            }
            gard_.move();
            break;
        }

        return switch (gard_.orientation) {
            .UP => self.get(gard_.position).?.visited_by.up,
            .DOWN => self.get(gard_.position).?.visited_by.down,
            .LEFT => self.get(gard_.position).?.visited_by.left,
            .RIGHT => self.get(gard_.position).?.visited_by.right,
        };
    }

    fn isNextPositionVisitedAny(self: Map) bool {
        var gard_ = self.gard;
        for (0..4) |_| {
            if (self.get(gard_.inFront()).?.type_ == .Obstacle) {
                gard_.rotate();
                continue;
            }
            gard_.move();
            break;
        }

        return self.get(gard_.position).?.visitedAny();
    }

    fn next(self: *Map) ?void {
        // Check upfront
        switch (self.look().type_) {
            .End => return null,
            .Empty => {
                self.gard.move();
                self.setVisited(self.gard);
            },
            .Obstacle => {
                self.gard.rotate();
                self.setVisited(self.gard);
                return self.next();
            },
        }
    }

    fn setVisited(self: *Map, gard: Gard) void {
        switch (gard.orientation) {
            .UP => self.buff[@as(usize, @intCast(gard.position.x))][@as(usize, @intCast(gard.position.y))].visited_by.up = true,
            .DOWN => self.buff[@as(usize, @intCast(gard.position.x))][@as(usize, @intCast(gard.position.y))].visited_by.down = true,
            .LEFT => self.buff[@as(usize, @intCast(gard.position.x))][@as(usize, @intCast(gard.position.y))].visited_by.left = true,
            .RIGHT => self.buff[@as(usize, @intCast(gard.position.x))][@as(usize, @intCast(gard.position.y))].visited_by.right = true,
        }
    }

    fn printMap(self: Map) !void {
        var array = std.ArrayList(u8).init(self.allocator);
        defer array.deinit();
        const writer = array.writer();

        for (self.buff, 0..) |row, x| {
            try writer.writeByte('\n');
            for (row, 0..) |cell, y| {
                if (self.gard.position.x == x and self.gard.position.y == y) {
                    try writer.writeByte('X');
                    continue;
                }
                switch (cell.type_) {
                    .Obstacle => try writer.writeByte('#'),
                    .Empty => {
                        if (self.founded_loop.contains(Position{ .x = @as(i16, @intCast(x)), .y = @as(i16, @intCast(y)) })) {
                            try writer.writeByte('0');
                        } else if ((cell.visited_by.up or cell.visited_by.down) and (cell.visited_by.left or cell.visited_by.right)) {
                            try writer.writeByte('+');
                        } else if (cell.visited_by.up or cell.visited_by.down) {
                            try writer.writeByte('|');
                        } else if (cell.visited_by.right or cell.visited_by.left) {
                            try writer.writeByte('-');
                        } else {
                            try writer.writeByte(' ');
                        }
                    },
                    .End => try writer.writeByte('E'),
                }
            }
        }

        print("{s}", .{array.items});
    }

    fn isInLoop(self: *Map) !bool {
        const initial_buff = self.buff;
        const initial_gard = self.gard;

        defer self.buff = initial_buff;
        defer self.gard = initial_gard;

        while (self.next()) |_| {
            if (self.isNextPositionVisited()) return true;
        }

        return false;
    }

    fn set(self: *Map, position: Position, point: Point) void {
        self.buff[@as(usize, @intCast(position.x))][@as(usize, @intCast(position.y))] = point;
    }

    fn get(self: Map, position: Position) ?Point {
        if (0 > position.x or position.x >= 132 or 0 > position.y or position.y >= 132) return null;
        return self.buff[@as(usize, @intCast(position.x))][@as(usize, @intCast(position.y))];
    }

    fn look(self: Map) Point {
        const position = self.gard.inFront();
        return self.buff[@as(usize, @intCast(position.x))][@as(usize, @intCast(position.y))];
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    // ========= Parse map ===========
    var iter = std.mem.split(u8, file, "\n");
    var map = try Map.init(allocator);
    defer map.deinit();

    for (0..132) |x| {
        for (0..132) |y| {
            map.buff[x][y] = Point{};
        }
    }

    var x: usize = 1;
    while (iter.next()) |line| {
        for (line, 1..) |c, y| switch (c) {
            '.' => map.buff[x][y].type_ = .Empty,
            '#' => map.buff[x][y].type_ = .Obstacle,
            '^' => {
                map.gard.position = .{ .x = @as(i16, @intCast(x)), .y = @as(i16, @intCast(y)) };
                map.buff[x][y].type_ = .Empty;
                map.buff[x][y].visited_by.up = true;
            },
            else => unreachable,
        };
        x += 1;
    }

    // ========= Make the gard move to the end ===========
    var total: usize = 0;
    const start_map = map;

    while (map.next()) |_| {
        var map2 = start_map;
        map2.set(map.gard.position, Point{ .type_ = .Obstacle });

        if (try map2.isInLoop()) {
            if (!map.founded_loop.contains(map.gard.position)) total += 1;
            try map.founded_loop.put(map.gard.position, {});
        }
    }

    try std.testing.expectEqual(2008, total);
}

fn progressBar(value: usize, max: usize, size: usize, writer: anytype) !void {
    try writer.writeByte('|');
    const nb_fill = @divFloor(size * value, max);
    for (0..nb_fill) |_| try writer.writeByte('=');
    for (0..size - nb_fill) |_| try writer.writeByte(' ');
    try writer.writeByte('|');
    try writer.print(" {d}/{d}", .{ value, max });
}

fn clearScreen() void {
    print("\x1B[2J\x1B[H", .{});
}
