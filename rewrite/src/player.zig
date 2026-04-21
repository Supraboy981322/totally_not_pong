const rl = @import("raylib");

pub const Player = struct {
    color:rl.Color,
    shape:rl.Rectangle,
    speed:f32,

    pub fn init(width:i32, height:i32) Player {
        return .{
            .color = .white,
            .speed = 2,
            .shape = .{
                .x = 10,
                .y = @floatFromInt(@divExact((rl.getScreenWidth() - height), @as(u32, 2))),
                .width = @floatFromInt(width),
                .height = @floatFromInt(height),
            },
        };
    }

    pub fn can_move(self:*Player, direction:enum{ up, down }) bool {
        const pos =
            if (direction == .down)
                self.shape.y + self.shape.height
            else
                self.shape.y;

        const limit:f32 =
            if (direction == .down)
                @floatFromInt(rl.getScreenHeight())
            else
                0;

        return
            if (direction == .down)
                pos < limit
            else
                pos > limit;
    }
};
