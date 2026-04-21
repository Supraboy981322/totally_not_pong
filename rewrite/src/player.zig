const rl = @import("raylib");

pub const Player = struct {
    color:rl.Color,
    shape:rl.Rectangle,

    pub fn init(width:i32, height:i32) Player {
        return .{
            .color = .white,
            .shape = .{
                .x = 10,
                .y = @floatFromInt(@divExact((rl.getScreenWidth() - height), @as(u32, 2))),
                .width = @floatFromInt(width),
                .height = @floatFromInt(height),
            },
        };
    }
};
