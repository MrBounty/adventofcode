const std = @import("std");
const print = std.debug.print;
const file = @embedFile("input");

const Rule = struct {
    left: usize,
    right: usize,

    fn ok(self: Rule, sub_page: Rule) bool {
        return !(sub_page.left == self.right and sub_page.right == self.left);
    }
};

const PageIterator = struct {
    indexL: usize = 0,
    indexR: usize = 0,
    buff: []usize,

    fn next(self: *PageIterator) ?Rule {
        self.indexR += 1;

        if (self.indexR == self.buff.len) {
            self.indexL += 1;
            self.indexR = self.indexL + 1;
        }

        if (self.indexL == (self.buff.len - 1)) return null;

        return Rule{
            .left = self.buff[self.indexL],
            .right = self.buff[self.indexR],
        };
    }

    fn reset(self: *PageIterator) void {
        self.indexL = 0;
        self.indexR = 1;
    }

    fn swap(self: *PageIterator) void {
        const buffR: usize = self.buff[self.indexR];
        self.buff[self.indexR] = self.buff[self.indexL];
        self.buff[self.indexL] = buffR;
    }
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();
    defer {
        const deinit_status = gpa.deinit();
        if (deinit_status == .leak) @panic("TEST FAIL");
    }

    // ========= Parse Rules ===========
    var bad_rules = std.AutoHashMap(Rule, void).init(allocator);
    defer bad_rules.deinit();

    var iter = std.mem.split(u8, file, "\n");
    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) break;

        _ = try bad_rules.put(Rule{
            .right = try std.fmt.parseInt(usize, line[0..2], 10),
            .left = try std.fmt.parseInt(usize, line[3..5], 10),
        }, {});
    }

    // ========= Evaluate ===========
    var page = std.ArrayList(usize).init(allocator);
    defer page.deinit();

    var total: usize = 0;
    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) break;
        defer page.clearRetainingCapacity();

        var sub_iter = std.mem.split(u8, line, ",");
        while (sub_iter.next()) |value_str| {
            try page.append(try std.fmt.parseInt(usize, value_str, 10));
        }

        total += try evaluate(bad_rules, page.items);
    }

    try std.testing.expectEqual(6949, total);
}

fn evaluate(bad_rules: std.AutoHashMap(Rule, void), page: []usize) !usize {
    var iter = PageIterator{ .indexL = 0, .indexR = 0, .buff = page };

    defer iter.reset();
    while (iter.next()) |sub_page| {
        if (bad_rules.contains(sub_page)) return 0;
    }
    const middle = try std.math.divFloor(usize, page.len, 2);
    return page[middle];
}
