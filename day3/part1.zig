const std = @import("std");
const print = std.debug.print;

const LookingFor = enum {
    m,
    u,
    l,
    l_brace,
    X,
    Y,
};

var file_buf: [1024 * 1024]u8 = undefined; // The file do 20kB, I give it 1MB

pub fn main() !void {
    const file = try std.fs.cwd().openFile("day3/input", .{});
    defer file.close();
    const len = try file.readAll(&file_buf);

    try std.testing.expectEqual(190604937, try parse(file_buf[0..len]));
}

fn parse(input: []const u8) !u32 {
    var state: LookingFor = .m;
    var total: u32 = 0;
    var intX_len: u8 = 0;
    var intY_len: u8 = 0;
    for (input, 0..) |c, i| switch (state) {
        .m => switch (c) {
            'm' => state = .u,
            else => continue,
        },
        .u => switch (c) {
            'u' => state = .l,
            else => state = .m,
        },
        .l => switch (c) {
            'l' => state = .l_brace,
            else => state = .m,
        },
        .l_brace => switch (c) {
            '(' => {
                state = .X;
                intX_len = 0;
                intY_len = 0;
            },
            else => state = .m,
        },
        .X => switch (c) {
            ',' => state = if (intX_len > 0) .Y else .m,
            '0'...'9' => if (intX_len == 3) {
                state = .m;
            } else {
                intX_len += 1;
            },
            else => state = .m,
        },
        .Y => switch (c) {
            ')' => {
                state = .m;
                if (intY_len > 0) {
                    const x = try std.fmt.parseInt(u32, input[i - (intX_len + intY_len + 1) .. i - intY_len - 1], 10);
                    const y = try std.fmt.parseInt(u32, input[i - intY_len .. i], 10);
                    total += x * y;
                }
            },
            '0'...'9' => {
                if (intY_len == 3) {
                    state = .m;
                    continue;
                }
                intY_len += 1;
            },
            else => state = .m,
        },
    };
    return total;
}
