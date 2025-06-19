const std = @import("std");
const azync = @import("azync");
const Runtime = azync.Runtime;

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    // Initialize the async runtime with default number of CPU cores
    const rt = try Runtime.init(allocator);
    defer rt.deinit();

    // Spawn async tasks, passing parameters as a tuple
    const future1 = try rt.spawn(returnNumber, .{});
    const future2 = try rt.spawn(allocateHelloWorld, .{allocator});
    const future3 = try rt.spawn(appendWorldToSlice, .{"hello", allocator});

    // Await task results. The type passed must match the async function's return type!
    const result1 = future1.Await(i32);
    const result2 = future2.Await([]const u8);
    const result3 = future3.Await([]const u8);

    defer allocator.free(result2);
    defer allocator.free(result3);

    // Print the results with newlines for clarity
    std.debug.print("Result 1: {d}\n", .{result1});
    std.debug.print("Result 2: {s}\n", .{result2});
    std.debug.print("Result 3: {s}\n", .{result3});
}

/// Returns a constant number synchronously
fn returnNumber() i32 {
    return 42;
}

/// Allocates and returns the string "hello world!" in the given allocator
fn allocateHelloWorld(allocator: std.mem.Allocator) ![]const u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    _ = try buffer.appendSlice("hello");
    _ = try buffer.appendSlice(" world!");

    return try buffer.toOwnedSlice();
}

/// Appends " world!" to a provided slice, allocating in the given allocator
fn appendWorldToSlice(s: []const u8, allocator: std.mem.Allocator) ![]const u8 {
    var buffer = std.ArrayList(u8).init(allocator);
    defer buffer.deinit();

    _ = try buffer.appendSlice(s);
    _ = try buffer.appendSlice(" world!");

    return try buffer.toOwnedSlice();
}
