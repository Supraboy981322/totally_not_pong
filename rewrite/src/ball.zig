const rl = @import("raylib");
const player = @import("player.zig");
const PlayerSet = player.PlayerSet;
const Player = player.Player;
const Side = @import("types.zig").Side;

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
                .x = @floatFromInt(rl.getRandomValue(-5, 5)),
                .y = 4.0,
            },
            .pos = .{
                .x = @floatFromInt(@divExact(rl.getScreenWidth(), 2)),
                .y = @floatFromInt(@divExact(rl.getScreenHeight(), 2)),
            },
        };
    }

    pub fn tick(self:*Ball, players:PlayerSet, dt:f32) ?Side {
        var touching_side:?Side = null;

        const actual_speed:rl.Vector2 = .{
            .x = self.speed.x * dt * 75,
            .y = self.speed.y * dt * 75,
        };

        self.pos.x += actual_speed.x;
        self.pos.y += actual_speed.y;

        const on_player = self.touching_player(players);
        if (self.touching_edge(null) or on_player != null) {
            self.speed.x *= -1.0;
            if (on_player) |pos|
                self.pos.x = pos
            else
                touching_side = if (self.touching_edge(.left)) .left else .right;
        }

        const h_edge:f32 = @as(f32, @floatFromInt(rl.getScreenHeight())) - self.radius;
        if (self.pos.y >= h_edge or self.pos.y <= self.radius)
            self.speed.y *= -1.0;

        return touching_side;
    }

    pub fn draw(self:*Ball) void {
        rl.drawCircleV(
            self.pos, self.radius, self.color,
        );
    }

    pub fn touching_edge(self:*Ball, side:?Side) bool {
        const w_edge:f32 = @as(f32, @floatFromInt(rl.getScreenWidth())) - self.radius;
        const at_right_edge = self.pos.x >= w_edge;
        const at_left_edge = self.pos.x <= self.radius;
        const at_w_edge = at_right_edge or at_left_edge;
        return
            if (side) |s|
                if (s == .left)
                    at_left_edge
                else
                    at_right_edge
            else
                at_w_edge;
    }

    pub fn touching_player(self:*Ball, players:PlayerSet) ?f32 {
        loop: for (&[_]Player{ players.p1, players.p2 }) |*p| {//players.p2}) |*p| {
            const pos_width = p.shape.x + if (p.side == .left) p.box.width else 0;
            for ([_]bool{
                p.shape.y + p.box.height >= self.pos.y + self.radius,
                p.shape.y <= self.pos.y,
                if (p.side == .left) pos_width >= self.pos.x else pos_width <= self.pos.x
            }) |check|
                if (!check) continue :loop;
            return pos_width;
        }
        return null;
    }
};
