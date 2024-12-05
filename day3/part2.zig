const std = @import("std");
const print = std.debug.print;

const LookingFor = enum {
    m_or_d,
    u,
    l,
    l_brace_mul,
    X,
    Y,
    o,
    t,
    apostrophe,
    l_brace_do,
    l_brace_do_or_n,
    r_brace_do,
};

var file_buf: [1024 * 1024]u8 = undefined; // The file do 20kB, I give it 1MB

pub fn main() !void {
    const file = try std.fs.cwd().openFile("day3/input", .{});
    defer file.close();

    const len = try file.readAll(&file_buf);

    try std.testing.expectEqual(82857512, try parse(file_buf[0..len]));
}

fn parse(input: []const u8) !u32 {
    var state: LookingFor = .m_or_d;
    var total: u32 = 0;
    var intX_len: u8 = 0;
    var intY_len: u8 = 0;
    var enable = true;
    var enable_buff: bool = true;
    for (input, 0..) |c, i| switch (state) {
        .m_or_d => switch (c) {
            'm' => state = .u,
            'd' => state = .o,
            else => continue,
        },
        .u => switch (c) {
            'u' => state = .l,
            else => state = .m_or_d,
        },
        .l => switch (c) {
            'l' => state = .l_brace_mul,
            else => state = .m_or_d,
        },
        .o => switch (c) {
            'o' => state = .l_brace_do_or_n,
            else => state = .m_or_d,
        },
        .t => switch (c) {
            't' => state = .l_brace_do,
            else => state = .m_or_d,
        },
        .apostrophe => switch (c) {
            '\'' => state = .t,
            else => state = .m_or_d,
        },
        .l_brace_mul => switch (c) {
            '(' => {
                state = .X;
                intX_len = 0;
                intY_len = 0;
            },
            else => state = .m_or_d,
        },
        .l_brace_do => switch (c) {
            '(' => state = .r_brace_do,
            else => state = .m_or_d,
        },
        .l_brace_do_or_n => switch (c) {
            '(' => state = .r_brace_do,
            'n' => {
                enable_buff = false;
                state = .apostrophe;
            },
            else => state = .m_or_d,
        },
        .r_brace_do => switch (c) {
            ')' => {
                enable = enable_buff;
                enable_buff = true;
                state = .m_or_d;
            },
            else => state = .m_or_d,
        },
        .X => switch (c) {
            ',' => state = if (intX_len > 0) .Y else .m_or_d,
            '0'...'9' => if (intX_len == 3) {
                state = .m_or_d;
            } else {
                intX_len += 1;
            },
            else => state = .m_or_d,
        },
        .Y => switch (c) {
            ')' => {
                state = .m_or_d;
                if (intY_len > 0) {
                    if (!enable) continue;
                    const x = try std.fmt.parseInt(u32, input[i - (intX_len + intY_len + 1) .. i - intY_len - 1], 10);
                    const y = try std.fmt.parseInt(u32, input[i - intY_len .. i], 10);
                    total += x * y;
                }
            },
            '0'...'9' => {
                if (intY_len == 3) {
                    state = .m_or_d;
                    continue;
                }
                intY_len += 1;
            },
            else => state = .m_or_d,
        },
    };
    return total;
}
