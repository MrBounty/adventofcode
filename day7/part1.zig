const std = @import("std");
const print = std.debug.print;
const file = @embedFile("input");

// Look like the complexity is 2 ^ (n - 1)
// with n len of a int list
//
// So that mean I need to do

const Operator = struct {
    value: usize,
    list: []usize,
};

pub fn main() !void {
    // const test_value = "190: 10 19\n3267: 81 40 27\n83: 17 5\n156: 15 6\n7290: 6 8 6 15\n161011: 16 10 13\n192: 17 8 14\n21037: 9 7 18 13\n292: 11 6 16 20";
    var iter = std.mem.split(u8, file, "\n");
    var total: usize = 0;
    while (iter.next()) |line| {
        if (std.mem.eql(u8, line, "")) continue;
        total += try parseOperator(line);
    }

    try std.testing.expectEqual(882304362421, total);
}

fn parseOperator(line: []const u8) !usize {
    var number_buff: [12]usize = undefined;
    var result_buff: [2048]usize = undefined; // 2 ^ 11

    var main_split = std.mem.split(u8, line, ":");
    const left_value: usize = try std.fmt.parseInt(usize, main_split.next().?, 10);

    var iter = std.mem.split(u8, main_split.next().?, " ");
    _ = iter.next(); // Skip the first space after :
    var len: usize = 0;
    while (iter.next()) |number| {
        defer len += 1;
        number_buff[len] = try std.fmt.parseInt(usize, number, 10);
    }

    // So here I need to iterate over all combinaison of + and *, how can I do that ?
    // I can do a tree with 2 branch at each step, the result of the new node is the entry value + or * current node
    // But I need keep in memory all previous number, it's useless, I just need to know the value of all combinaison of the list
    // Im sure I can take advantages that operations are done left to right, it would be even easier
    // So I start with an empty usize list -> I take the 2 fist value -> I do + and * and add them to the list ->
    // -> Take the next number, and do + and * on all of what is inside the list, remove previous item and add them to the list
    // -> Do that over and over until the end and check how  many left value are in the list

    result_buff[0] = number_buff[0];
    for (0..len - 1) |i| {
        const number_count = std.math.pow(usize, 2, i); // This is the number of value in the result buffer

        // For all number in the list, I add them + new value at the end of the list (number_count + index) and then replace themself by them * new_value
        for (0..number_count) |j| {
            result_buff[number_count + j] = result_buff[j] + number_buff[i + 1];
            result_buff[j] = result_buff[j] * number_buff[i + 1];
        }
    }

    // Now I have all result of all combinaison of the list, I just need to check how many are left_value
    const all_results = result_buff[0..std.math.pow(usize, 2, len - 1)];

    var total: usize = 0;
    for (all_results) |result| {
        if (result == left_value) {
            total += left_value;
            break;
        }
    }

    return total;
}
