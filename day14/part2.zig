const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const Int = i16;
const MAP_SIZE: [2]Int = .{ 101, 103 };

// I am pretty sure that I can detect the tree by using the distance of each drone from each drone
// Something like that, some kind of noise
// If they picture a tree, it mean they are close to each other right ? So it is less 'noisy' or less enthropy

const Drone = struct {
    x: Int,
    y: Int,
    vX: Int,
    vY: Int,

    fn next(self: *Drone) void {
        const mapW = MAP_SIZE[0];
        const mapH = MAP_SIZE[1];
        self.x += self.vX;
        self.y += self.vY;

        // Dected boundary
        if (self.x >= mapW) self.x -= mapW; //Move back to 0 + xt1 - mapW
        if (self.x < 0) self.x += mapW;
        if (self.y >= mapH) self.y -= mapH;
        if (self.y < 0) self.y += mapH;
    }

    fn detectQuadrant(self: Drone, mapW: Int, mapH: Int) enum { TopLeft, TopRight, BottomLeft, BottomRight, None } {
        if (self.x < @divFloor(mapW, 2)) {
            if (self.y < @divFloor(mapH, 2)) return .TopLeft;
            if (self.y > @divFloor(mapH, 2)) return .BottomLeft;
        } else if (self.x > @divFloor(mapW, 2)) {
            if (self.y < @divFloor(mapH, 2)) return .TopRight;
            if (self.y > @divFloor(mapH, 2)) return .BottomRight;
        }
        return .None;
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    const drones = try parseDrone(allocator);

    var list = std.ArrayList(u8).init(allocator);
    const writer = list.writer();

    for (0..10000) |i| {
        list.clearRetainingCapacity();
        for (drones) |*drone| drone.next();
        if (!detectIfDroneClose(drones, 40, 2)) continue;

        clearScreen();
        try printDrone(writer, drones);
        print("{s}\nTime: {d}s", .{ list.items, i });
        try waitForInput();
    }
}

fn parseDrone(allocator: std.mem.Allocator) ![]Drone {
    var list = std.ArrayList(Drone).init(allocator);

    var iter = std.mem.splitAny(u8, input, "\n");
    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) continue;
        var iter_space = std.mem.splitAny(u8, line, " ");

        const part1 = iter_space.next().?;
        var iter_comma = std.mem.splitAny(u8, part1, ",");
        const x = try std.fmt.parseInt(Int, iter_comma.next().?[2..], 10);
        const y = try std.fmt.parseInt(Int, iter_comma.next().?, 10);

        const part2 = iter_space.next().?;
        iter_comma = std.mem.splitAny(u8, part2, ",");
        const vX = try std.fmt.parseInt(Int, iter_comma.next().?[2..], 10);
        const vY = try std.fmt.parseInt(Int, iter_comma.next().?, 10);

        try list.append(Drone{ .x = x, .y = y, .vX = vX, .vY = vY });
    }

    return try list.toOwnedSlice();
}

fn printDrone(writer: anytype, drones: []const Drone) !void {
    var buf: [MAP_SIZE[0]][MAP_SIZE[1]]u8 = [_][MAP_SIZE[1]]u8{[_]u8{0} ** MAP_SIZE[1]} ** MAP_SIZE[0];
    for (drones) |drone| {
        const x = @as(usize, @intCast(drone.x));
        const y = @as(usize, @intCast(drone.y));
        buf[x][y] += 1;
    }

    for (buf) |line| {
        for (line) |v| {
            if (v == 0) {
                try writer.writeByte(' ');
            } else {
                try writer.writeByte('0');
            }
        }
        try writer.writeByte('\n');
    }
}

// Detect if at least 10 drones have 10 other drones close it it
fn detectIfDroneClose(drones: []Drone, to_find: usize, distance_max: f64) bool {
    var founded1: usize = 0;
    for (drones) |drone1| {
        var founded2: usize = 0;
        for (drones) |drone2| {
            if (distance(drone1, drone2) < distance_max) founded2 += 1;
        }
        if (founded2 > to_find) founded1 += 1;
    }
    return founded1 > to_find;
}

pub fn distance(drone1: Drone, drone2: Drone) f64 {
    const dx = @as(f64, @floatFromInt(drone2.x - drone1.x));
    const dy = @as(f64, @floatFromInt(drone1.y - drone1.y));
    return std.math.sqrt(dx * dx + dy * dy);
}

fn clearScreen() void {
    print("\x1B[2J\x1B[H", .{});
}

fn waitForInput() !void {
    var buf: [5]u8 = undefined;
    const stdin = std.io.getStdIn().reader();
    _ = try stdin.readUntilDelimiter(&buf, '\n');
}
