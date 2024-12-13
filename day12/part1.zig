const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAP_SIZE = 140;

const Area = struct {
    positions: *std.AutoHashMap([2]usize, void),
    char: u8,
    perimeter: usize = 0,
    area: usize = 0,

    fn init(allocator: std.mem.Allocator, char: u8) !Area {
        const positions = try allocator.create(std.AutoHashMap([2]usize, void));
        positions.* = std.AutoHashMap([2]usize, void).init(allocator);
        return Area{
            .positions = positions,
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

    fn printMap(self: Map) void {
        for (0..MAP_SIZE + 2) |x| {
            print("\n", .{});
            for (0..MAP_SIZE + 2) |y| print("{c}", .{self.map[x][y]});
        }
        print("\n", .{});
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

    fn printAreas(self: Map) void {
        for (self.areas.items) |area| {
            print("Region {c} with Perimeter: {d}; and Area: {d}\n", .{ area.char, area.perimeter, area.area });
        }
    }

    fn printAreasOneByOne(self: Map) !void {
        for (self.areas.items) |area| {
            clearScreen();
            print("Region {c} with Perimeter: {d}; and Area: {d}\n", .{ area.char, area.perimeter, area.area });
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
        self.checkBorder(x, y);
        self.areas.items[self.areas.items.len - 1].area += 1;
        try self.areas.items[self.areas.items.len - 1].positions.put([2]usize{ x, y }, {});
        if (self.map[x - 1][y] != '.' and self.map[x - 1][y] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x - 1, y })) try self.lookAround(x - 1, y);
        if (self.map[x + 1][y] != '.' and self.map[x + 1][y] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x + 1, y })) try self.lookAround(x + 1, y);
        if (self.map[x][y - 1] != '.' and self.map[x][y - 1] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x, y - 1 })) try self.lookAround(x, y - 1);
        if (self.map[x][y + 1] != '.' and self.map[x][y + 1] == self.map[x][y] and !self.areas.getLast().positions.contains([2]usize{ x, y + 1 })) try self.lookAround(x, y + 1);
    }

    fn checkBorder(self: *Map, x: usize, y: usize) void {
        if (self.map[x + 1][y] != self.map[x][y]) self.areas.items[self.areas.items.len - 1].perimeter += 1; //Down
        if (self.map[x - 1][y] != self.map[x][y]) self.areas.items[self.areas.items.len - 1].perimeter += 1; //Down
        if (self.map[x][y - 1] != self.map[x][y]) self.areas.items[self.areas.items.len - 1].perimeter += 1; //Left
        if (self.map[x][y + 1] != self.map[x][y]) self.areas.items[self.areas.items.len - 1].perimeter += 1; //Right
    }

    fn calculPrice(self: Map) usize {
        var total: usize = 0;
        for (self.areas.items) |area| {
            total += area.perimeter * area.area;
        }
        return total;
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
    try std.testing.expectEqual(1375476, map.calculPrice());
}

fn clearScreen() void {
    print("\x1B[2J\x1B[H", .{});
}

fn waitForInput() !void {
    var buf: [5]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    _ = try stdin.readUntilDelimiter(&buf, '\n');
}
