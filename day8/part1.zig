const std = @import("std");
const print = std.debug.print;

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

    // Some basic vector operation. I get the vecto to go from A to B, then apply it from B to C. C is the place of one antinode.
    // I do the same A minus vector to get D, the second antinode
    fn antinodesPositions(self: Position, to: Position) [2]?Position {
        const diff = to.minus(self);
        const pos1 = self.minus(diff);
        const pos2 = to.add(diff);

        return [2]?Position{
            if (pos1.x < 0 or pos1.y >= MAP_SIZE or pos1.y < 0 or pos1.x >= MAP_SIZE) null else pos1,
            if (pos2.x < 0 or pos2.y >= MAP_SIZE or pos2.y < 0 or pos2.x >= MAP_SIZE) null else pos2,
        };
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

    // Lets make a function that take an antenna, find all other antenna with same char, useing 2 position find 2 new, then add to list
    fn addAntinodes(self: *Map, char: u8) void {
        // So here I need to loop over all cells -> find first of this char -> look for next of -> add 2 antinodes ->
        // -> Find the next of same char and add antinodes -> do it for all cells -> Repeat but skip first, then 2 first, etc
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

                    const antinodes_positions = left_cell.position.antinodesPositions(cell.position);
                    if (antinodes_positions[0]) |pos| self.addAntinodeToCell(pos, char);
                    if (antinodes_positions[1]) |pos| self.addAntinodeToCell(pos, char);
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

    const file = try std.fs.cwd().openFile("day8/input", .{});
    defer file.close();

    const file_size = (try file.stat()).size;
    const buffer = try allocator.alloc(u8, file_size);
    defer allocator.free(buffer);

    _ = try file.readAll(buffer);

    var map = Map{ .unique_antenna = std.AutoHashMap(u8, usize).init(allocator) };
    defer map.unique_antenna.deinit();
    var iter = std.mem.split(u8, buffer, "\n");
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
        map.addAntinodes(key.*);
    }

    try std.testing.expectEqual(228, map.countUniqueAntinodes());
}
