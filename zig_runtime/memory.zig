const std = @import("std");

pub fn allocate(size: usize) ?*u8 {
    return std.heap.page_allocator.alloc(u8, size) catch null;
}

pub fn free(ptr: *u8) void {
    std.heap.page_allocator.free(ptr);
}

