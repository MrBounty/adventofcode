const std = @import("std");
const print = std.debug.print;
const file = @embedFile("input");

// Take first free space and last file and swap

const Block = struct {
    id: ?usize,
    type_: enum { file, empty },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    var total_file_block: usize = 0;
    var total_free_block: usize = 0;

    var list = std.ArrayList(Block).init(allocator);
    for (file[0 .. file.len - 1], 0..) |c, i| {
        const number = c - '0';
        if (i % 2 == 0) {
            total_file_block += number;
            for (0..number) |_| try list.append(Block{ .id = @divFloor(i, 2), .type_ = .file });
        } else {
            total_free_block += number;
            for (0..number) |_| try list.append(Block{ .id = null, .type_ = .empty });
        }
    }

    sort(list.items, total_file_block);
    try std.testing.expectEqual(6401092019345, checksum(list.items, total_file_block));
}

fn checksum(list: []Block, total_file_block: usize) usize {
    var total: usize = 0;
    for (list[0..total_file_block], 0..) |block, i| total += block.id.? * i;
    return total;
}

fn sort(list: []Block, total_file_block: usize) void {
    var left_index: usize = 0;
    var right_index: usize = list.len - 1;
    var block_buff: Block = undefined;

    // I dont want a while loop where I check the list everytime, I need to know the number of swap that I need to do and use a for loop
    // Like that I dont need to check if the list is sorted, it will be at the end of the for loop
    // To know how many to move I need to know the number of file block and free block. This I can do it when I parse the first time.
    // Then I can parse the list one time and for each type not at the right position, it's a swap, then divide by 2

    for (0..total_swap_needed(list, total_file_block)) |_| {
        left_index = next_empty_block(list, left_index).?;
        right_index = next_file_block(list, right_index).?;

        block_buff = list[left_index];
        list[left_index] = list[right_index];
        list[right_index] = block_buff;
    }
}

fn next_empty_block(list: []Block, index: usize) ?usize {
    for (index..list.len) |i| if (list[i].type_ == .empty) return i;
    return null;
}

fn next_file_block(list: []Block, index: usize) ?usize {
    for (0..index) |i| if (list[index - i].type_ == .file) return (index - i);
    return null;
}

fn total_swap_needed(list: []Block, total_file_block: usize) usize {
    var total: usize = 0;
    for (list, 0..) |block, i| {
        if ((block.type_ == .file and i > total_file_block) or (block.type_ == .empty and i < total_file_block)) total += 1;
    }
    return @divFloor(total, 2);
}
