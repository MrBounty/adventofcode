const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const MAP_SIZE = 141;

// So so so, how do I do that ?
// I am thinking bruteforce but stop early if the score is already > min
// Otherwise I can do it from the rnf, I dont need to do from start to end. I can do from end to start
// I cant really brute force it either though. As their is an infinite number of path since I can go around for ever
// So start from the start and making a random next step is a bit stupide it seem
// Specially because I think the next part will be a freaking giant map of something like that
// So first of all, rotation is 1000 cost lol. So Basically I need to find the lower number of turn until the end.
// If there is 2 identical, I check how many case it is. And maybe they are the same. You can do left right and right left, same price.
// But what matter is the number of turn
// Ok so what I can do it for each intersection, I do do all possible turn. But I need to do the step one by one
// I cant use recursion. Because I stop at the first found solution
// Damn that a good solution tho I think, as it will always take the minimum amount of calculation for 100% sure it's the minimum.
// Because Iam sure I can find a pathfinding algo somewhere that find the best at 95% but using 1% of the time.
//
// Anyway, so how do I do that ?
// I think I have a list of position + direction and a step function
// At each step, I go at the end of strait line and append to the next list if I find a possible route
// Like that it count like one turn and the next step it fo strait line
// When I found something the touch the exit I STILL FINISH THE CURRENT LIST as another one can finish at the same time in less cost
//
// If I need to turn 2 time, that mean I am in a cue de sac. So I can just forget it and don't add it to the next list

const Direction = enum { Top, Bottom, Left, Right };

const Cell = struct {
    is: enum { Wall, Empty, End },
    visited_by: struct {
        top: bool = false,
        bottom: bool = false,
        left: bool = false,
        right: bool = false,
    } = .{},

    fn visit(self: *Cell, direction: Direction) void {
        if (direction == .Top) self.visited_by.top = true;
        if (direction == .Left) self.visited_by.left = true;
        if (direction == .Right) self.visited_by.right = true;
        if (direction == .Bottom) self.visited_by.bottom = true;
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
    fn solve(self: *Map, allocator: std.mem.Allocator) !?usize {
        var minimum: ?usize = null;
        while (minimum == null and self.paths.items.len != 0) {
            const paths = try allocator.alloc(Path, self.paths.items.len);
            defer allocator.free(paths);
            for (self.paths.items, 0..) |path, i| paths[i] = path;
            self.paths.clearRetainingCapacity();

            for (paths) |*path| blk: while (true) {
                var x: usize = path.position.x;
                if (path.direction == .Top) x -= 1 else if (path.direction == .Bottom) x += 1;
                var y: usize = path.position.y;
                if (path.direction == .Left) y -= 1 else if (path.direction == .Right) y += 1;

                if (self.map[x][y].is == .Wall) break :blk;
                if (self.map[x][y].is == .End) {
                    if (minimum == null or path.number_of_turn_done * 1000 + path.number_of_tile_walked < minimum.?) {
                        minimum = path.number_of_turn_done * 1000 + path.number_of_tile_walked;
                    }
                    break :blk;
                }
                if (self.map[x][y].visited(path.direction)) break :blk;
                self.map[x][y].visit(path.direction);
                path.number_of_tile_walked += 1;
                path.position.x = x;
                path.position.y = y;
                try self.checkSurroundingAndCreatePath(path.*);
            };
        }
        return minimum;
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
                });
                if (self.map[x + 1][y].is == .Empty and !self.map[x + 1][y].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Bottom,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
                });
            }, //
            .Top, .Bottom => {
                if (self.map[x][y - 1].is == .Empty and !self.map[x][y - 1].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Left,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
                });
                if (self.map[x][y + 1].is == .Empty and !self.map[x][y + 1].visited(path.direction)) try self.paths.append(Path{
                    .position = path.position,
                    .direction = .Right,
                    .number_of_tile_walked = path.number_of_tile_walked,
                    .number_of_turn_done = path.number_of_turn_done + 1,
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
    const minimum = try map.solve(allocator);
    try std.testing.expectEqual(127520, minimum.?);
}
