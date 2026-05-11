const rl = @import("raylib");
const Ball = @import("ball.zig");
const Side = @import("types.zig").Side;

pub const PlayerSet = struct {
    p1:Player,
    p2:Player,
    pub fn init(p1:Player, p2:Player) PlayerSet {
        return .{
            .p1 = p1,
            .p2 = p2,
        };
    }
};

const Player = @This();

color:rl.Color,
shape:rl.Rectangle,
speed:f32,
points:usize = 0,

box:struct {
    width:f32,
    height:f32,
},

auto:bool = false,
ball:*Ball = undefined,

side:Side,

btns:struct {
    up:rl.KeyboardKey = .null,
    down:rl.KeyboardKey = .null,
    pub fn init(side:Side) @This() {
        return .{
            .up = if (side == .left) .k else .f,
            .down = if (side == .left) .j else .d,
        };
    }
},

pub fn init(width:i32, height:i32, auto:bool, side:Side, ball:*Ball, color:rl.Color) Player {
    const w:f32, const h:f32 = .{
        @floatFromInt(width),
        @floatFromInt(height),
    };
    return .{
        .color = color,
        .speed = 5,
        .auto = auto,
        .btns = .init(side),
        .side = side,
        .ball = if (auto) ball else undefined,
        .box = .{
            .width = w + 10,
            .height = h + 10,
        },
        .shape = .{
            .x = if (side == .left) 10 else @floatFromInt(rl.getScreenWidth() - 10),
            .y = @floatFromInt(@divExact((rl.getScreenWidth() - height), @as(u32, 2))),
            .width = w,
            .height = h,
        },
    };
}

pub fn can_move(self:*Player, direction:enum{ up, down }) bool {
    const pos =
        if (direction == .down)
            self.shape.y + self.box.height
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

pub fn tick(self:*Player, dt:f32) void {
    const screen_height = rl.getScreenHeight();
    self.shape.height = @floatFromInt(@divTrunc(screen_height, 10));
    self.shape.width = @floatFromInt(@divTrunc(@as(u32, @intFromFloat(self.shape.height)), 5));
    self.box.height = self.shape.height + 5;
    self.box.width = self.shape.width + 5;

    if (self.side == .right)
        self.shape.x = @as(f32, @floatFromInt(rl.getScreenWidth() - 10)) - self.box.width;

    self.speed = @floatFromInt(@divTrunc(screen_height, 30));

    const actual_speed = self.speed * dt * 50;

    if (self.auto) {
        if (self.ball.pos.y < self.shape.y and self.can_move(.up))
            self.shape.y -= actual_speed; 

        if (self.ball.pos.y > self.shape.y + self.box.height and self.can_move(.down))
            self.shape.y += actual_speed;
    } else {
        if (rl.isKeyDown(self.btns.up) and self.can_move(.up))
            self.shape.y -= actual_speed;

        if (rl.isKeyDown(self.btns.down) and self.can_move(.down))
            self.shape.y += actual_speed;
    }
}

pub fn draw(self:*Player) void {
    rl.drawRectangleRec(self.shape, self.color);
}
