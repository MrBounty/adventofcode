const std = @import("std");
const print = std.debug.print;

const UP = Position{ .x = -1, .y = 0 };
const RIGHT = Position{ .x = 0, .y = 1 };
const DOWN = Position{ .x = 1, .y = 0 };
const LEFT = Position{ .x = 0, .y = -1 };

const Point = enum { Empty, Obstacle, Visited, End };

const Position = struct {
    x: i16,
    y: i16,

    fn move(self: *Position, to: Position) void {
        self.x += to.x;
        self.y += to.y;
    }

    fn rotate(self: *Position) void {
        if (std.meta.eql(self.*, UP)) {
            self.* = RIGHT;
            return;
        }
        if (std.meta.eql(self.*, RIGHT)) {
            self.* = DOWN;
            return;
        }
        if (std.meta.eql(self.*, DOWN)) {
            self.* = LEFT;
            return;
        }
        if (std.meta.eql(self.*, LEFT)) {
            self.* = UP;
            return;
        }
    }
};

const Map = struct {
    buff: [132][132]Point = undefined,
    gard_position: Position = undefined,
    gard_orientation: Position = UP,

    fn next(self: *Map) ?bool {
        // Check upfront
        var new_visite: ?bool = false;
        switch (self.look()) {
            .End => return null,
            .Empty => {
                new_visite = true;
                self.gard_position.move(self.gard_orientation);
                self.buff[@as(usize, @intCast(self.gard_position.x))][@as(usize, @intCast(self.gard_position.y))] = .Visited;
            },
            .Visited => self.gard_position.move(self.gard_orientation),
            .Obstacle => {
                self.gard_orientation.rotate();
                new_visite = self.next();
            },
        }
        return new_visite;
    }

    fn printMap(self: Map, writer: anytype) !void {
        for (self.buff, 0..) |row, x| {
            try writer.writeByte('\n');
            for (row, 0..) |cell, y| {
                if (self.gard_position.x == x and self.gard_position.y == y) {
                    try writer.writeByte('X');
                    continue;
                }
                switch (cell) {
                    .Obstacle => try writer.writeByte('#'),
                    .Empty => try writer.writeByte(' '),
                    .Visited => try writer.writeByte('.'),
                    .End => try writer.writeByte('E'),
                }
            }
        }
    }

    fn get(self: Map, position: Position) Point {
        return self.buff[@as(usize, @intCast(position.x))][@as(usize, @intCast(position.y))];
    }

    fn look(self: Map) Point {
        return self.buff[@as(usize, @intCast(self.gard_position.x + self.gard_orientation.x))][@as(usize, @intCast(self.gard_position.y + self.gard_orientation.y))];
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    // ========= Load file ===========
    const file = try std.fs.cwd().openFile("day6/input", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    // ========= Parse map ===========
    var iter = std.mem.split(u8, buffer, "\n");
    var map = Map{};

    for (0..132) |x| {
        for (0..132) |y| {
            map.buff[x][y] = .End;
        }
    }

    var x: usize = 1;
    while (iter.next()) |line| {
        for (line, 1..) |c, y| switch (c) {
            '.' => map.buff[x][y] = .Empty,
            '#' => map.buff[x][y] = .Obstacle,
            '^' => {
                map.gard_position = .{ .x = 1 + @as(i16, @intCast(x)), .y = @as(i16, @intCast(y)) };
                map.buff[x][y] = .Empty;
            },
            else => unreachable,
        };
        x += 1;
    }

    // ========= Make the gard move to the end ===========
    //var map_array = std.ArrayList(u8).init(allocator);
    //defer map_array.deinit();
    var total: usize = 0;
    while (map.next()) |new_visite| {
        //defer map_array.clearRetainingCapacity();
        //try map.printMap(map_array.writer());
        if (new_visite) total += 1;
        //clearScreen();
        //print("{s}", .{map_array.items});
        //std.time.sleep(2000000);
    }

    try std.testing.expectEqual(5516, total);
}

fn clearScreen() void {
    print("\x1B[2J\x1B[H", .{});
}
