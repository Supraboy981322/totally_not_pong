const std = @import("std");
const rl = @import("raylib");
const hlp = @import("helpers.zig");
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
        .init(15, 50, false, .left, &ball),
        .init(15, 50, true, .right, &ball)
    );

    var state:types.State = .init();

    rl.setExitKey(.null);
    loop: while (!rl.windowShouldClose()) : (try state.tick()) {
        if (hlp.is_ctrl_down() and rl.isKeyDown(.c))
            break :loop;

        if (rl.isKeyDown(.escape)) {
            state.is_paused = state.is_paused;
        }

        if (state.is_paused) {
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
            if (rl.isKeyReleased(.escape)) state.toggle_pause();
            continue;
        }

        const touching_side = ball.tick(player_set);
        if (touching_side) |side| {
            if (side == .left)
                player_set.p2.points += 1
            else
                player_set.p1.points += 1;
        }
        player_set.p1.tick();
        player_set.p2.tick();

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        ball.draw();
        player_set.p1.draw();
        player_set.p2.draw();
        try state.draw(player_set);
    }
}
