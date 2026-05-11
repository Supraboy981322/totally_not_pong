const std = @import("std");
const rl = @import("raylib");
const hlp = @import("helpers.zig");
const Player = @import("player.zig");
const PlayerSet = Player.PlayerSet;

pub const Side = enum {
    left, right,
};

pub const State = struct {
    frame_count:u6 = 0,

    screen:struct {
        height_f32:f32 = undefined,
        width_f32:f32 = undefined,
    } = .{},

    arena:std.heap.ArenaAllocator,

    aux:struct{
        buf:[]u8 = undefined,
        arraylist:std.ArrayList(u8) = undefined,
        num:isize = 0,
        unum:usize = 0,
        boolean:bool = false,
    } = .{},

    menu:enum{
        win,
        start,
        match_opts,
        in_game,
        paused,
    } = .start,

    opts:struct{
        goal:usize = 10,
        player_count:?u1 = null, //null for full auto
    } = .{},

    pub fn init() State {
        return .{
            .arena = std.heap.ArenaAllocator.init(std.heap.page_allocator),
        };
    }

    pub fn toggle_pause(self:*State) void {
        switch (self.menu) {
            .in_game => self.menu = .paused,
            .paused => self.menu = .in_game,
            else => @panic("toggle_pause() outside of game mode"),
        }
    }

    pub fn tick(self:*State) !void {
        self.screen.height_f32 = @floatFromInt(rl.getScreenHeight());
        self.screen.width_f32 = @floatFromInt(rl.getScreenWidth());
        
        defer _ = self.arena.reset(.free_all);
        const alloc = self.arena.allocator();
        _ = alloc;
        self.frame_count = @mod(self.frame_count + 1, 60);
        if (rl.isKeyDown(.escape) and (self.menu == .in_game or self.menu == .paused)) {
            while (rl.isKeyDown(.escape)) : (rl.pollInputEvents()) {}
            self.toggle_pause();
        }
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
