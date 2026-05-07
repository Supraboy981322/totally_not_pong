const std = @import("std");
const rg = @import("raygui");
const rl = @import("raylib");
const hlp = @import("helpers.zig");
const menu = @import("menus.zig");
const player = @import("player.zig");
const PlayerSet = player.PlayerSet;
const Player = player.Player;
const Ball = @import("ball.zig").Ball;
const types = @import("types.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    rl.initWindow(800, 450, "totally not pong (100%)");
    defer rl.closeWindow();

    // WARNING: DO NOT REMOVE THIS (for now)
    // on my particular Hyprland install (NixOS + Nvidia + scrolling)
    //  window launches on wrong monitor and Hyprland thinks it's on the
    //    primary monitor, so if you don't move the window before attempting
    //      to change windows, Hyprland crashes entirely
    if (rl.getMonitorCount() > 1)
        rl.setWindowMonitor(1);
    
    rl.setTargetFPS(60);

    var ball:Ball = .init(14);

    var player_set:PlayerSet = .init(
        .init(15, 50, false, .left, &ball, .red),
        .init(15, 50, true, .right, &ball, .blue)
    );

    var state:types.State = .init();
    state.aux.arraylist = try .initCapacity(alloc, 0);
    defer state.aux.arraylist.deinit(alloc);
    state.aux.buf = try alloc.alloc(u8, 0);
    defer alloc.free(state.aux.buf);

    rl.setExitKey(.null);
    loop: while (!rl.windowShouldClose()) : (try state.tick()) {
        if (hlp.is_ctrl_down() and rl.isKeyDown(.c))
            break :loop;

        switch (state.menu) {

            .win => try menu.render_win(&state, alloc, player_set),

            .start, .match_opts => try menu.render_menu(&state, alloc),

            .paused => {
                rl.beginDrawing();
                defer rl.endDrawing();
                rl.clearBackground(.dark_gray);
                const msgs = [_][:0]const u8{
                    "game paused.",
                    "press escape to unpause, or ctrl+c to quit",
                };
                for (msgs, 0..) |line, i| {
                    const txt_width = rl.measureText(
                        line,
                        30,
                    );
                    const v_offset:i32 = @intCast(30 + (50 * (msgs.len - i - 1)));
                    rl.drawText(
                        line,
                        @divTrunc((rl.getScreenWidth() - txt_width), 2),
                        @divTrunc(rl.getScreenHeight() - v_offset, 2),
                        30,
                        .white,
                    );
                }
                rl.pollInputEvents();
            },

            .in_game => {
                const touching_side = ball.tick(player_set);
                if (touching_side) |side| {
                    if (side == .left)
                        player_set.p2.points += 1
                    else
                        player_set.p1.points += 1;
                }
                player_set.p1.tick();
                player_set.p2.tick();

                for ([_]Player{ player_set.p1, player_set.p2 }) |p|
                    if (p.points >= state.opts.goal) {
                        state.menu = .win;
                        state.aux.boolean = true;
                    };

                rl.beginDrawing();
                defer rl.endDrawing();
                rl.clearBackground(.black);

                ball.draw();
                player_set.p1.draw();
                player_set.p2.draw();
                try state.draw(player_set);
            },
        }
    }
}
