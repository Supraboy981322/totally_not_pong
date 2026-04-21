const rl = @import("raylib");
const hlp = @import("helpers.zig");
const Player = @import("player.zig").Player;
const Ball = @import("ball.zig").Ball;
const types = @import("types.zig");

pub fn main() !void {
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

    var p1:Player = .init(15, 50);
    var ball:Ball = .init(14);

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

        ball.tick(.{ .p1 = p1, .p2 = undefined, });
        p1.tick();

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        ball.draw();
        p1.draw();
    }
}
