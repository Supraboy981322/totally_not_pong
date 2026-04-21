const rl = @import("raylib");
const player = @import("player.zig");
const PlayerSet = player.PlayerSet;
const Player = player.Player;

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

    pub fn tick(self:*Ball, players:PlayerSet) void {
        self.pos.x += self.speed.x;
        self.pos.y += self.speed.y;

        const w_edge:f32 = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.radius;
        const at_w_edge = self.pos.x >= w_edge or self.pos.x <= self.radius;
        const on_player = self.touching_player(players);
        if (at_w_edge or on_player != null) {
            self.speed.x *= -1.0;
            if (on_player) |pos|
                self.pos.x = pos;
        }

        const h_edge:f32 = @as(f32, @floatFromInt(rl.getScreenHeight())) - self.radius;
        if (self.pos.y >= h_edge or self.pos.y <= self.radius)
            self.speed.y *= -1.0;
    }

    pub fn draw(self:*Ball) void {
        rl.drawCircleV(
            self.pos, self.radius, self.color,
        );
    }

    pub fn touching_player(self:*Ball, players:PlayerSet) ?f32 {
        loop: for (&[_]Player{ players.p1, }) |*p| {//players.p2}) |*p| {
            for ([_]bool{
                p.shape.y + p.shape.height >= self.pos.y + self.radius,
                p.shape.y <= self.pos.y,
                p.shape.x + p.shape.width >= self.pos.x
            }) |check|
                if (!check) continue :loop;
            return p.shape.x + p.shape.width;
        }
        return null;
    }
};
