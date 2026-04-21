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
    loop: while (!rl.windowShouldClose()) {
        defer state.tick();

        if (hlp.is_ctrl_down() and rl.isKeyDown(.c))
            break :loop;

        if (state.is_paused) {
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
