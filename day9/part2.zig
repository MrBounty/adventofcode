const std = @import("std");
const print = std.debug.print;
const file = @embedFile("input");
//const file = "2333133121414131402\n";

// I think I just need to change both next function
// The e;pty block now take a size argument
// And the file take the current file index

const Block = struct {
    id: ?usize,
    type_: enum { file, empty },
};

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const max_file_index = @divFloor(file.len - 1, 2);

    // 1. create the list
    var list = std.ArrayList(Block).init(allocator);
    defer list.deinit();
    for (file[0 .. file.len - 1], 0..) |c, i| {
        if (i % 2 == 0) {
            for (0..c - '0') |_| try list.append(Block{ .id = @divFloor(i, 2), .type_ = .file });
        } else {
            for (0..c - '0') |_| try list.append(Block{ .id = null, .type_ = .empty });
        }
    }

    sort(list.items, max_file_index);
    try std.testing.expectEqual(6431472344710, checksum(list.items));
}

fn checksum(list: []Block) usize {
    var total: usize = 0;
    for (list, 0..) |block, i| total += if (block.id) |id| id * i else 0;
    return total;
}

fn sort(list: []Block, max_file_index: usize) void {
    for (0..max_file_index) |i| {
        const result = file_size_index(list, max_file_index - i) orelse continue;
        const index = empty_space(list, result[0]) orelse continue;
        if (index > result[1]) continue;
        swap_memory(list, result[1], index, result[0]);
    }
}

fn empty_space(list: []Block, size: usize) ?usize {
    var mesuring: bool = false;
    var len: usize = 0;
    for (list, 0..) |block, i| {
        if (mesuring and len == size) return (i - len);
        if (block.type_ == .empty and !mesuring) {
            mesuring = true;
            len = 1;
        } else if (block.type_ == .file and mesuring) {
            mesuring = false;
            len = 0;
        } else if (block.type_ == .empty and mesuring) len += 1;
    }
    return null;
}

fn file_size_index(list: []Block, file_index: usize) ?[2]usize {
    var mesuring: bool = false;
    var len: usize = 0;
    for (list, 0..) |block, i| {
        if (!mesuring and block.id == file_index) {
            mesuring = true;
            len = 1;
        } else if (mesuring and (block.type_ != .empty and block.type_ == .file and block.id.? == file_index)) {
            len += 1;
        } else if (mesuring and (block.type_ == .empty or (block.type_ == .file and block.id.? != file_index))) return [2]usize{ len, i - len };
    }
    return [2]usize{ len, list.len - len };
}

fn swap_memory(list: []Block, from: usize, to: usize, len: usize) void {
    var buf: [9]Block = undefined;
    for (to..to + len, 0..len) |i, j| buf[j] = list[i];
    for (to..to + len, from..from + len) |i, j| list[i] = list[j];
    for (from..from + len, 0..len) |i, j| list[i] = buf[j];
}
