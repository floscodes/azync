# azync

[![CI](https://github.com/floscodes/azync/actions/workflows/ci.yml/badge.svg)](https://github.com/floscodes/azync/actions/workflows/ci.yml)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)

azync is a small experimental runtime for running asynchronous tasks in Zig.

> [!WARNING]
> azync is still in development and is _not_ ready for production yet.

## Minimal Example

```zig
const std = @import("std");
const azync = @import("azync");
const Runtime = azync.Runtime;

fn main() void {
    const allocator = std.heap.page_allocator;
    const rt = Runtime.init(allocator) catch unreachable;
    defer rt.deinit();

    const future = rt.spawn(myAsyncFunction, .{}) catch unreachable;
    const result = future.Await(i32);
    std.debug.print("Result: {d}\n", .{result});
}

fn myAsyncFunction() i32 {
    return 42;
}
```

For a complete example showcasing advanced usage with dynamic allocations and multiple parameters, see [examples/basic.zig](./examples/basic.zig).

## Overview

azync spawns as many worker threads as logical CPU cores available on your machine. These threads continuously pick up and run asynchronous tasks you spawn via `Runtime.spawn`. Finished tasks remain in the task queue until you call the `Await()` method on the associated `*Future` to retrieve the result.

> [!NOTE]
> `Await` is written with a capital "A" to avoid clashing with Zig's reserved `await` keyword.

You can also control the number of worker threads by initializing the runtime with a specific core count using `initWithCores()`:

```zig
const allocator = std.heap.page_allocator;
const rt = Runtime.initWithCores(allocator, 16) catch unreachable;
defer rt.deinit();
```
