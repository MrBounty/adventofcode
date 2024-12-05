const std = @import("std");
const print = std.debug.print;

var file_buf: [140 * 141]u8 = undefined;
var matrice: [142][142]u8 = undefined;
const masks = [_][3][3]u8{
    [3][3]u8{
        [3]u8{ 'M', ' ', 'S' },
        [3]u8{ ' ', 'A', ' ' },
        [3]u8{ 'M', ' ', 'S' },
    },
    [3][3]u8{
        [3]u8{ 'M', ' ', 'M' },
        [3]u8{ ' ', 'A', ' ' },
        [3]u8{ 'S', ' ', 'S' },
    },
    [3][3]u8{
        [3]u8{ 'S', ' ', 'S' },
        [3]u8{ ' ', 'A', ' ' },
        [3]u8{ 'M', ' ', 'M' },
    },
    [3][3]u8{
        [3]u8{ 'S', ' ', 'M' },
        [3]u8{ ' ', 'A', ' ' },
        [3]u8{ 'S', ' ', 'M' },
    },
};

pub fn main() !void {
    setMatrice('.');
    try fillMatrice();
    try std.testing.expectEqual(1822, countMask());
}

fn evaluate(mask: [3][3]u8, sub: [3][3]u8) bool {
    var count: u4 = 0;

    for (mask, sub) |maskX, subX| {
        for (maskX, subX) |maskY, subY| {
            count += if (maskY == subY) 1 else 0;
        }
    }

    return count == 5;
}

fn setMatrice(c: u8) void {
    for (0..142) |x| {
        for (0..142) |y| {
            matrice[x][y] = c;
        }
    }
}

fn fillMatrice() !void {
    const file = try std.fs.cwd().openFile("day4/input", .{});
    defer file.close();

    _ = try file.readAll(&file_buf);

    var iter = std.mem.split(u8, &file_buf, "\n");

    var x: usize = 1;
    while (iter.next()) |line| {
        defer x += 1;

        for (line, 1..) |c, y| {
            matrice[x][y] = c;
        }
    }
}

fn countMask() u32 {
    var total: u32 = 0;

    var iter = MatriceIterator.init();

    while (iter.next()) |sub| {
        for (masks) |mask| {
            total += if (evaluate(mask, sub)) 1 else 0;
        }
    }

    return total;
}

const MatriceIterator = struct {
    x: u32 = 0,
    y: u32 = 0,
    return_buf: [3][3]u8 = undefined,

    fn init() MatriceIterator {
        return MatriceIterator{};
    }

    fn next(self: *MatriceIterator) ?[3][3]u8 {
        if (self.x == 139 and self.y == 139) return null;
        self.y += 1;
        if (self.y == 140) {
            self.x += 1;
            self.y = 0;
        }

        for (self.x..(self.x + 3), 0..) |x, a| {
            for (self.y..(self.y + 3), 0..) |y, b| {
                self.return_buf[a][b] = matrice[x][y];
            }
        }

        return self.return_buf;
    }
};
