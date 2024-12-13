const std = @import("std");
const print = std.debug.print;
const input = "890 0 1 935698 68001 3441397 7221 27";
const numberT = u64;

// Passed to a weird while loop instead of recurcive function because I run into limitation, too much recursion :/

const Stone = struct {
    number: numberT,
    next: ?*Stone = null,

    fn step(self: *Stone, allocator: std.mem.Allocator) !void {
        var current = self;
        while (true) {
            if (current.number == 0) {
                current.number = 1;
                if (current.next) |right_stone| {
                    current = right_stone;
                } else {
                    break;
                }
            } else if (digitCount(current.number) % 2 == 0) {
                const new_value = splitNumber(current.number);
                const new_stone = try allocator.create(Stone);
                new_stone.* = Stone{ .number = new_value[1], .next = current.next };
                current.number = new_value[0];
                current.next = new_stone;
                if (new_stone.next) |right_stone| {
                    current = right_stone;
                } else {
                    break;
                }
            } else {
                current.number *= 2024;
                if (current.next) |right_stone| {
                    current = right_stone;
                } else {
                    break;
                }
            }
        }
    }

    fn printStone(self: Stone) void {
        print("{d} ", .{self.number});
        if (self.right) |right_stone| {
            right_stone.printStone();
        } else {
            print("\n", .{});
        }
    }

    fn count(self: *Stone, total: *usize) void {
        var current = self;
        while (true) {
            total.* += 1;
            if (current.next) |right_stone| {
                current = right_stone;
            } else {
                break;
            }
        }
    }
};

pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();
    const allocator = arena.allocator();

    var iter = std.mem.splitAny(u8, input, " ");
    const first_stone = try allocator.create(Stone);
    first_stone.* = Stone{ .number = try std.fmt.parseInt(numberT, iter.next().?, 10) };

    var last_stone = first_stone;
    while (iter.next()) |number| {
        const new_stone = try allocator.create(Stone);
        new_stone.* = Stone{ .number = try std.fmt.parseInt(numberT, number, 10) };
        last_stone.next = new_stone;
        last_stone = new_stone;
    }

    for (0..25) |_| try first_stone.step(allocator);

    var total: usize = 0;
    first_stone.count(&total);
    try std.testing.expectEqual(194782, total);
}

fn digitCount(num: numberT) usize {
    if (num == 0) return 1;

    var n = num;
    var count: usize = 0;
    while (n != 0) : (n = @divFloor(n, 10)) {
        count += 1;
    }
    return count;
}

fn splitNumber(num: numberT) [2]numberT {
    const numDigits = digitCount(num);
    const halfDigits = numDigits / 2;

    var divisor: numberT = 1;
    for (halfDigits) |_| {
        divisor *= 10;
    }

    const left = @divFloor(num, divisor);
    const right = num % divisor;

    return [2]numberT{ left, right };
}
