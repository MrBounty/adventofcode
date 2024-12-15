const std = @import("std");
const print = std.debug.print;
const input = @embedFile("input");
const Int = i16;
const MAP_SIZE: [2]Int = .{ 101, 103 };

pub fn main() !void {
    var tl_quadrant: usize = 0;
    var tr_quadrant: usize = 0;
    var bl_quadrant: usize = 0;
    var br_quadrant: usize = 0;

    const mapW = MAP_SIZE[0];
    const mapH = MAP_SIZE[1];

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

        const end_pos = posFinal(x, y, vX, vY, mapW, mapH, 100);
        switch (detectQuadrant(end_pos[0], end_pos[1], mapW, mapH)) {
            .TopLeft => tl_quadrant += 1,
            .TopRight => tr_quadrant += 1,
            .BottomLeft => bl_quadrant += 1,
            .BottomRight => br_quadrant += 1,
            .None => {},
        }
    }

    print("Total: {d}\n", .{tl_quadrant * tr_quadrant * bl_quadrant * br_quadrant});
}

fn posFinal(x0: Int, y0: Int, vX: Int, vY: Int, mapW: Int, mapH: Int, dt: Int) [2]Int {
    var t: Int = 0;
    var x: Int = x0;
    var y: Int = y0;
    while (t < dt) : (t += 1) {
        x = x + vX;
        y = y + vY;

        // Dected boundary
        if (x >= mapW) x = x - mapW; //Move back to 0 + xt1 - mapW
        if (x < 0) x = mapW + x;
        if (y >= mapH) y = y - mapH;
        if (y < 0) y = mapH + y;
    }
    return [2]Int{ x, y };
}

fn detectQuadrant(x: Int, y: Int, mapW: Int, mapH: Int) enum { TopLeft, TopRight, BottomLeft, BottomRight, None } {
    if (x < @divFloor(mapW, 2)) {
        if (y < @divFloor(mapH, 2)) return .TopLeft;
        if (y > @divFloor(mapH, 2)) return .BottomLeft;
    } else if (x > @divFloor(mapW, 2)) {
        if (y < @divFloor(mapH, 2)) return .TopRight;
        if (y > @divFloor(mapH, 2)) return .BottomRight;
    }
    return .None;
}
