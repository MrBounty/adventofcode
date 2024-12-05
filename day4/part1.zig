const std = @import("std");
const print = std.debug.print;

var file_buf: [140 * 141]u8 = undefined;
var matrice: [143][143]u8 = undefined;
const masks = [_][4][4]u8{
    [4][4]u8{
        [4]u8{ ' ', ' ', ' ', ' ' },
        [4]u8{ 'X', 'M', 'A', 'S' },
        [4]u8{ ' ', ' ', ' ', ' ' },
        [4]u8{ ' ', ' ', ' ', ' ' },
    },
    [4][4]u8{
        [4]u8{ ' ', ' ', ' ', ' ' },
        [4]u8{ 'S', 'A', 'M', 'X' },
        [4]u8{ ' ', ' ', ' ', ' ' },
        [4]u8{ ' ', ' ', ' ', ' ' },
    },
    [4][4]u8{
        [4]u8{ ' ', 'X', ' ', ' ' },
        [4]u8{ ' ', 'M', ' ', ' ' },
        [4]u8{ ' ', 'A', ' ', ' ' },
        [4]u8{ ' ', 'S', ' ', ' ' },
    },
    [4][4]u8{
        [4]u8{ ' ', 'S', ' ', ' ' },
        [4]u8{ ' ', 'A', ' ', ' ' },
        [4]u8{ ' ', 'M', ' ', ' ' },
        [4]u8{ ' ', 'X', ' ', ' ' },
    },
    [4][4]u8{
        [4]u8{ 'X', ' ', ' ', ' ' },
        [4]u8{ ' ', 'M', ' ', ' ' },
        [4]u8{ ' ', ' ', 'A', ' ' },
        [4]u8{ ' ', ' ', ' ', 'S' },
    },
    [4][4]u8{
        [4]u8{ 'S', ' ', ' ', ' ' },
        [4]u8{ ' ', 'A', ' ', ' ' },
        [4]u8{ ' ', ' ', 'M', ' ' },
        [4]u8{ ' ', ' ', ' ', 'X' },
    },
    [4][4]u8{
        [4]u8{ ' ', ' ', ' ', 'X' },
        [4]u8{ ' ', ' ', 'M', ' ' },
        [4]u8{ ' ', 'A', ' ', ' ' },
        [4]u8{ 'S', ' ', ' ', ' ' },
    },
    [4][4]u8{
        [4]u8{ ' ', ' ', ' ', 'S' },
        [4]u8{ ' ', ' ', 'A', ' ' },
        [4]u8{ ' ', 'M', ' ', ' ' },
        [4]u8{ 'X', ' ', ' ', ' ' },
    },
};

pub fn main() !void {
    setMatrice('.');
    try fillMatrice();
    try std.testing.expectEqual(2401, countMask());
}

fn evaluate(mask: [4][4]u8, sub: [4][4]u8) bool {
    var count: u3 = 0;

    for (mask, sub) |maskX, subX| {
        for (maskX, subX) |maskY, subY| {
            count += if (maskY == subY) 1 else 0;
        }
    }

    return count == 4;
}

fn setMatrice(c: u8) void {
    for (0..143) |x| {
        for (0..143) |y| {
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
    return_buf: [4][4]u8 = undefined,

    fn init() MatriceIterator {
        return MatriceIterator{};
    }

    fn next(self: *MatriceIterator) ?[4][4]u8 {
        if (self.x == 139 and self.y == 139) return null;
        self.y += 1;
        if (self.y == 140) {
            self.x += 1;
            self.y = 0;
        }

        for (self.x..(self.x + 4), 0..) |x, a| {
            for (self.y..(self.y + 4), 0..) |y, b| {
                self.return_buf[a][b] = matrice[x][y];
            }
        }

        return self.return_buf;
    }
};

test "evaluate" {
    const toEval = [4][4]u8{
        [4]u8{ '.', '.', '.', '.' },
        [4]u8{ 'X', 'M', 'A', 'S' },
        [4]u8{ '.', '.', '.', '.' },
        [4]u8{ '.', '.', '.', '.' },
    };
    try std.testing.expect(evaluate(masks[0], toEval));
}
