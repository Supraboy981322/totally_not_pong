const std = @import("std");
const rl = @import("raylib");

pub const State = struct {
    is_paused:bool = false,
    frame_count:u6 = 0,

    arena:std.heap.ArenaAllocator,

    pub fn init() State {
        return .{
            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        };
    }

    pub fn toggle_pause(self:*State) void {
        self.is_paused = !self.is_paused;
    }

    pub fn tick(self:*State) !void {
        defer _ = self.arena.reset(.free_all);
        const alloc = self.arena.allocator();
        _ = alloc;
        self.frame_count = @mod(self.frame_count + 1, 60);
        if (rl.isKeyDown(.escape))
            self.is_paused =
                while (rl.isKeyDown(.escape)) : (rl.pollInputEvents()) {} else !self.is_paused;
    }
};
