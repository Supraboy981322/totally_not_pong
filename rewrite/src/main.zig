const rl = @import("raylib");
const Player = @import("player.zig").Player;
const Ball = @import("ball.zig").Ball;

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

    while (!rl.windowShouldClose()) {
        const screen_height, _ = .{
            rl.getScreenHeight(),
            rl.getScreenWidth(),
        };

        p1.shape.height = @floatFromInt(@divTrunc(screen_height, 10));
        p1.shape.width = @floatFromInt(@divTrunc(@as(u32, @intFromFloat(p1.shape.height)), 5));

        ball.tick();

        rl.beginDrawing();
        defer rl.endDrawing();

        ball.draw();

        rl.clearBackground(.black);
        rl.drawRectangleRec(p1.shape, p1.color);

        p1.speed = @floatFromInt(@divTrunc(screen_height, 30));

        if (rl.isKeyDown(.k) and p1.can_move(.up))
            p1.shape.y -= p1.speed;

        if (rl.isKeyDown(.j) and p1.can_move(.down))
            p1.shape.y += p1.speed;
    }
}
