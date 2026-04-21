const rl = @import("raylib");
const Player = @import("player.zig").Player;

pub fn main() !void {
    rl.initWindow(800, 450, "totally not pong (100%)");
    defer rl.closeWindow();

    rl.setTargetFPS(60);

    var p1:Player = .init(10, 20);

    while (!rl.windowShouldClose()) {
        rl.beginDrawing();
        defer rl.endDrawing();

        rl.clearBackground(.black);
        rl.drawRectangleRec(p1.shape, p1.color);
        p1.shape.y += 1;
    }
}
