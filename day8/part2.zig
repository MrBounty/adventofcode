const std = @import("std");
const print = std.debug.print;
const file = @embedFile("input");

// Agaain happy with the result, only needed to change few things

const MAP_SIZE = 50;

const Position = struct {
    x: i64,
    y: i64,

    /// Return a Position so self + returned = to
    fn minus(self: Position, to: Position) Position {
        return Position{ .x = self.x - to.x, .y = self.y - to.y };
    }

    fn add(self: Position, to: Position) Position {
        return Position{ .x = self.x + to.x, .y = self.y + to.y };
    }

    // Now I do a loop to add as much as long it is inside boundary
    fn antinodesPositions(self: Position, to: Position, allocator: std.mem.Allocator) ![]Position {
        var list = std.ArrayList(Position).init(allocator);
        const diff = to.minus(self);

        var left = self;
        while (left.inBoundary()) : (left = left.minus(diff)) try list.append(left);
        var right = to;
        while (right.inBoundary()) : (right = right.add(diff)) try list.append(right);

        return try list.toOwnedSlice();
    }

    fn outBoundary(self: Position) bool {
        return self.x < 0 or self.y >= MAP_SIZE or self.y < 0 or self.x >= MAP_SIZE;
    }

    fn inBoundary(self: Position) bool {
        return !self.outBoundary();
    }
};

const Cell = struct {
    position: Position,
    antenna: u8,
    antinodes: [20]u8 = [_]u8{'.'} ** 20,
    antinodes_len: usize = 0,

    fn haveAnyAntinode(self: Cell) bool {
        return self.antinodes[0] != '.';
    }
};

const Map = struct {
    cells: [MAP_SIZE][MAP_SIZE]Cell = undefined,
    unique_antenna: std.AutoHashMap(u8, usize),

    fn printMap(self: Map) !void {
        var array = std.ArrayList(u8).init(std.heap.page_allocator);
        defer array.deinit();
        const writer = array.writer();

        for (self.cells) |row| {
            for (row) |cell| try writer.writeByte(cell.antenna);
            try writer.writeByte('\n');
        }

        print("{s}", .{array.items});
    }

    fn addAntinodes(self: *Map, char: u8, parent_allocator: std.mem.Allocator) !void {
        var arena = std.heap.ArenaAllocator.init(parent_allocator);
        const allocator = arena.allocator();
        defer arena.deinit();

        const count_antenna = self.unique_antenna.get(char).?;

        for (0..count_antenna) |step| {
            var left_cell: Cell = undefined;
            var founded: usize = 0;
            for (self.cells) |row| for (row) |cell| {
                if (cell.antenna == char) {
                    defer founded += 1;
                    if (founded < step) continue;
                    if (founded == step) {
                        left_cell = cell;
                        continue;
                    }

                    const antinodes_positions = try left_cell.position.antinodesPositions(cell.position, allocator);
                    for (antinodes_positions) |pos| self.addAntinodeToCell(pos, char);
                }
            };
        }
    }

    fn addAntinodeToCell(self: *Map, position: Position, char: u8) void {
        var cell = self.cells[@as(usize, @intCast(position.x))][@as(usize, @intCast(position.y))];
        defer self.cells[@as(usize, @intCast(position.x))][@as(usize, @intCast(position.y))] = cell;

        cell.antinodes[cell.antinodes_len] = char;
        cell.antinodes_len += 1;
    }

    fn countUniqueAntinodes(self: Map) usize {
        var total: usize = 0;
        for (self.cells) |row| for (row) |cell| {
            if (cell.haveAnyAntinode()) total += 1;
        };

        return total;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    var map = Map{ .unique_antenna = std.AutoHashMap(u8, usize).init(allocator) };
    defer map.unique_antenna.deinit();
    var iter = std.mem.split(u8, file, "\n");
    var x: usize = 0;
    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) continue;
        defer x += 1;
        for (line, 0..) |c, y| switch (c) {
            '\n' => {},
            else => {
                map.cells[x][y] = Cell{ .position = Position{ .x = @as(i64, @intCast(x)), .y = @as(i64, @intCast(y)) }, .antenna = c };
                if (c != '.') try map.unique_antenna.put(c, 1 + (map.unique_antenna.get(c) orelse 0));
            },
        };
    }

    var keys = map.unique_antenna.keyIterator();
    while (keys.next()) |key| {
        try map.addAntinodes(key.*, allocator);
    }

    try std.testing.expectEqual(766, map.countUniqueAntinodes());
}
