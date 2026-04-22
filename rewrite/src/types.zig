const std = @import("std");
const hlp = @import("helpers.zig");
const player = @import("player.zig");
const Player = player.Player;
const PlayerSet = player.PlayerSet;
const rl = @import("raylib");

pub const Side = enum {
    left, right,
};

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

    pub fn draw(self:*State, player_set:PlayerSet) !void {
        const alloc = self.arena.allocator();
        for ([_]Player{ player_set.p1, player_set.p2 }) |p| {
            const score_txt = try hlp.fast_n_to_s(@TypeOf(p.points), p.points, alloc);
            const txt_width = rl.measureText(score_txt, 30) + 10;
            const w_offset:i32 = if (p.side == .left) -txt_width else txt_width;
            rl.drawText(
                score_txt,
                @divTrunc(rl.getScreenWidth() + w_offset, 2),
                50,
                30,
                .white,
            );
        }
    }
};
