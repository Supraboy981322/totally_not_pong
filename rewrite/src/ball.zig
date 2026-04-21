const rl = @import("raylib");

pub const Ball = struct {
    color:rl.Color,
    pos:rl.Vector2,
    radius:f32,
    speed:rl.Vector2,
    
    pub fn init(radius:f32) Ball {
        return .{
            .color = .white,
            .radius = radius,
            .speed = .{
                .x = 5.0,
                .y = 4.0,
            },
            .pos = .{
                .x = @floatFromInt(@divExact(rl.getScreenWidth(), 2)),
                .y = @floatFromInt(@divExact(rl.getScreenHeight(), 2)),
            },
        };
    }

    pub fn tick(self:*Ball) void {
        self.pos.x += self.speed.x;
        self.pos.y += self.speed.y;

        const w_edge:f32 = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.radius;
        if (self.pos.x >= w_edge or self.pos.x <= self.radius)
            self.speed.x *= -1.0;

        const h_edge:f32 = @as(f32, @floatFromInt(rl.getScreenHeight())) - self.radius;
        if (self.pos.y >= h_edge or self.pos.y <= self.radius)
            self.speed.y *= -1.0;
    }

    pub fn draw(self:*Ball) void {
        rl.drawCircleV(
            self.pos, self.radius, self.color,
        );
    }
};
