const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAP_SIZE = 140;

const Direction = enum { UP, DOWN, LEFT, RIGHT };

const Side = struct {
    start: [2]usize,
    end: [2]usize,
    direction: Direction,
};

const Area = struct {
    positions: *std.AutoHashMap([2]usize, void),
    sides: *std.ArrayList(Side), // start and end point
    char: u8,
    area: usize = 0,

    fn isInSide(self: Area, x: usize, y: usize, direction: Direction) bool {
        for (self.sides.items) |side| {
            if (direction != side.direction) continue;

            if (side.start[0] == side.end[0] and side.start[0] == x and side.start[1] <= y and y <= side.end[1]) return true;
            if (side.start[1] == side.end[1] and side.start[1] == y and side.start[0] <= x and x <= side.end[0]) return true;
        }
        return false;
    }

    fn init(allocator: std.mem.Allocator, char: u8) !Area {
        const positions = try allocator.create(std.AutoHashMap([2]usize, void));
        positions.* = std.AutoHashMap([2]usize, void).init(allocator);
        const sides = try allocator.create(std.ArrayList(Side));
        sides.* = std.ArrayList(Side).init(allocator);
        return Area{
            .positions = positions,
            .sides = sides,
            .char = char,
        };
    }
};

const Map = struct {
    allocator: std.mem.Allocator,
    map: [MAP_SIZE + 2][MAP_SIZE + 2]u8 = undefined,

    areas: *std.ArrayList(Area),
    area_search_x: usize = 0,
    area_search_y: usize = 0,

    fn init(allocator: std.mem.Allocator) !Map {
        const areas = try allocator.create(std.ArrayList(Area));
        areas.* = std.ArrayList(Area).init(allocator);
        return Map{
            .allocator = allocator,
            .areas = areas,
        };
    }

    fn setInput(self: *Map) void {
        for (input, 0..) |c, i| {
            if (c == '\n') continue;
            self.map[@divFloor(i, MAP_SIZE + 1) + 1][i % (MAP_SIZE + 1) + 1] = c;
        }
    }

    fn set(self: *Map, char: u8) void {
        for (0..MAP_SIZE + 2) |x| for (0..MAP_SIZE + 2) |y| {
            self.map[x][y] = char;
        };
    }

    fn posInArea(self: Map, x: usize, y: usize) bool {
        for (self.areas.items) |area| {
            if (area.positions.contains([2]usize{ x, y })) return true;
        }
        return false;
    }

    fn populateAreas(self: *Map) !void {
        for (1..MAP_SIZE + 1) |x| for (1..MAP_SIZE + 1) |y| {
            if (self.posInArea(x, y)) continue;
            try self.areas.append(try Area.init(self.allocator, self.map[x][y]));
            try self.lookAround(x, y);
        };
    }

    fn lookAround(self: *Map, x: usize, y: usize) !void {
        try self.checkSide(x, y);
        self.areas.items[self.areas.items.len - 1].area += 1;
        try self.areas.items[self.areas.items.len - 1].positions.put([2]usize{ x, y }, {});
        if (self.map[x - 1][y] != '.' and self.map[x - 1][y] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x - 1, y })) try self.lookAround(x - 1, y);
        if (self.map[x + 1][y] != '.' and self.map[x + 1][y] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x + 1, y })) try self.lookAround(x + 1, y);
        if (self.map[x][y - 1] != '.' and self.map[x][y - 1] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x, y - 1 })) try self.lookAround(x, y - 1);
        if (self.map[x][y + 1] != '.' and self.map[x][y + 1] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x, y + 1 })) try self.lookAround(x, y + 1);
    }

    fn checkSide(self: *Map, x: usize, y: usize) !void {
        if (self.map[x + 1][y] != self.map[x][y] and !self.areas.getLast().isInSide(x, y, .DOWN)) try self.addSide(x, y, .DOWN);
        if (self.map[x - 1][y] != self.map[x][y] and !self.areas.getLast().isInSide(x, y, .UP)) try self.addSide(x, y, .UP);
        if (self.map[x][y - 1] != self.map[x][y] and !self.areas.getLast().isInSide(x, y, .LEFT)) try self.addSide(x, y, .LEFT);
        if (self.map[x][y + 1] != self.map[x][y] and !self.areas.getLast().isInSide(x, y, .RIGHT)) try self.addSide(x, y, .RIGHT);
    }

    fn addSide(self: *Map, x: usize, y: usize, direction: Direction) !void {
        var start_x: usize = x;
        var start_y: usize = y;

        var end_x: usize = x;
        var end_y: usize = y;

        switch (direction) {
            .UP => {
                while (self.map[x][start_y - 1] == self.map[x][y] and self.map[x - 1][start_y - 1] != self.map[x][y]) start_y -= 1;
                while (self.map[x][end_y + 1] == self.map[x][y] and self.map[x - 1][end_y + 1] != self.map[x][y]) end_y += 1;
            },
            .DOWN => {
                while (self.map[x][start_y - 1] == self.map[x][y] and self.map[x + 1][start_y - 1] != self.map[x][y]) start_y -= 1;
                while (self.map[x][end_y + 1] == self.map[x][y] and self.map[x + 1][end_y + 1] != self.map[x][y]) end_y += 1;
            },
            .LEFT => {
                while (self.map[start_x - 1][y] == self.map[x][y] and self.map[start_x - 1][y - 1] != self.map[x][y]) start_x -= 1;
                while (self.map[end_x + 1][y] == self.map[x][y] and self.map[end_x + 1][y - 1] != self.map[x][y]) end_x += 1;
            },
            .RIGHT => {
                while (self.map[start_x - 1][y] == self.map[x][y] and self.map[start_x - 1][y + 1] != self.map[x][y]) start_x -= 1;
                while (self.map[end_x + 1][y] == self.map[x][y] and self.map[end_x + 1][y + 1] != self.map[x][y]) end_x += 1;
            },
        }

        try self.areas.items[self.areas.items.len - 1].sides.append(Side{
            .start = [2]usize{ start_x, start_y },
            .end = [2]usize{ end_x, end_y },
            .direction = direction,
        });
    }

    fn calculPrice(self: Map) usize {
        var total: usize = 0;
        for (self.areas.items) |area| {
            total += area.sides.items.len * area.area;
        }
        return total;
    }

    fn printPos(self: Map, x: usize, y: usize) void {
        for (0..MAP_SIZE + 2) |x2| {
            print("\n", .{});
            for (0..MAP_SIZE + 2) |y2| {
                if (x == x2 and y == y2) {
                    print("{c}", .{self.map[x][y]});
                } else {
                    print(".", .{});
                }
            }
        }
        print("\n", .{});
    }

    fn printAreasOneByOne(self: Map) !void {
        for (self.areas.items) |area| {
            clearScreen();
            print("Region {c} with Side: {d}; and Area: {d}\n", .{ area.char, area.sides.items.len, area.area });
            for (area.sides.items) |side| {
                print("Side {any}\n", .{side});
            }
            for (0..MAP_SIZE + 2) |x| {
                print("\n", .{});
                for (0..MAP_SIZE + 2) |y| {
                    if (area.positions.contains([2]usize{ x, y })) {
                        print("{c}", .{self.map[x][y]});
                    } else {
                        print(".", .{});
                    }
                }
            }
            print("\n", .{});
            try waitForInput();
        }
    }

    fn printAreasSideOneByOne(self: Map) !void {
        for (self.areas.items) |area| {
            for ([4]Direction{ .UP, .DOWN, .LEFT, .RIGHT }) |direction| {
                clearScreen();
                print("Region {c} with Side: {d}; and Area: {d}, Direction {any}\n", .{ area.char, area.sides.items.len, area.area, direction });
                for (0..MAP_SIZE + 2) |x| {
                    print("\n", .{});
                    for (0..MAP_SIZE + 2) |y| {
                        if (area.isInSide(x, y, direction)) {
                            print("{c}", .{self.map[x][y]});
                        } else {
                            print(".", .{});
                        }
                    }
                }
                print("\n", .{});
                try waitForInput();
            }
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var map = try Map.init(allocator);
    map.set('.');
    map.setInput();
    try map.populateAreas();
    //try map.printAreasSideOneByOne();
    try std.testing.expectEqual(821372, map.calculPrice());
}

fn clearScreen() void {
    print("\x1B[2J\x1B[H", .{});
}

fn waitForInput() !void {
    var buf: [5]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    _ = try stdin.readUntilDelimiter(&buf, '\n');
}
