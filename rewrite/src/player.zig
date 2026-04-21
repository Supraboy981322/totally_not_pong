const rl = @import("raylib");

pub const PlayerSet = struct {
    p1:Player,
    p2:Player,
};

pub const Player = struct {
    color:rl.Color,
    shape:rl.Rectangle,
    speed:f32,
    points:usize = 0,

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

    pub fn tick(self:*Player) void {
        const screen_height = rl.getScreenHeight();
        self.shape.height = @floatFromInt(@divTrunc(screen_height, 10));
        self.shape.width = @floatFromInt(@divTrunc(@as(u32, @intFromFloat(self.shape.height)), 5));
        self.speed = @floatFromInt(@divTrunc(screen_height, 30));

        if (rl.isKeyDown(.k) and self.can_move(.up))
            self.shape.y -= self.speed;

        if (rl.isKeyDown(.j) and self.can_move(.down))
            self.shape.y += self.speed;
    }

    pub fn draw(self:*Player) void {
        rl.drawRectangleRec(self.shape, self.color);
    }
};
