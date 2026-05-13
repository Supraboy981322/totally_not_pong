const std = @import("std");
const rl = @import("raylib");
const types = @import("types.zig");

pub fn is_ctrl_down() bool {
    return rl.isKeyDown(.left_control) or rl.isKeyDown(.right_control);
}

pub fn fast_n_to_s(T:type, n:T, alloc:std.mem.Allocator) ![:0]const u8 {
    var len:usize = 0;
    var num:T = n;
    while (num > 0) : (len += 1){
        num = @divFloor(num, 10);
    }
    const buf = try alloc.alloc(u8, len+1);
    defer alloc.free(buf);
    const end = std.fmt.printInt(buf, n, 10, .lower, .{});
    return try alloc.dupeZ(u8, buf[0..end]);
}

pub fn is_num(str:[]const u8) bool {
    return
        for (str) |b| {
            std.debug.print("{d} {x} |{c}|\n", .{b, b, b});
            if (b >= '9' or b <= '0')
                return false;
        } else
            true;
}

pub fn input_box(state:*types.State, alloc:std.mem.Allocator, y_pos:f32, valid:bool, validity_check:?*const fn(u8) bool) !bool {
    var input_txt = &state.aux.arraylist;

    const txt_box:rl.Rectangle = b: {
        const screen_width = @as(f32, @floatFromInt(rl.getScreenWidth()));
        const width:f32 = screen_width * 0.9;
        break :b .{
            .x = screen_width * 0.05,
            .y = y_pos,
            .width = width,
            .height = 35,
        };
    };

    var new_valid:bool = valid;

    {
        if (rl.isKeyDown(.left_control) or rl.isKeyDown(.right_control)) {
            if (rl.isKeyDown(.w) or rl.isKeyDown(.backspace))
                loop: while (input_txt.pop()) |b| if (std.ascii.isWhitespace(b)) break :loop;
        } else if (rl.isKeyDown(.backspace))
            _ = input_txt.pop();

        new_valid = blk: {
            var key = rl.getCharPressed();
            while (key != 0) : (key = rl.getCharPressed()) {
                if (key >= 32 and key <= 125) {
                    if (validity_check) |check|
                        if (!check(@intCast(key)))
                            break :blk false;
                    try input_txt.append(alloc, @intCast(key));
                }
            }
            break :blk true;
        };
    }

    rl.drawRectangleRec(txt_box, if (new_valid) .white else .red);

    const visible_input_buf:[:0]const u8 = b: {
        try input_txt.append(alloc, 0);
        var buf_len:f32 = @floatFromInt(rl.measureText(@ptrCast(input_txt.items), 20));
        var start:usize = 0;
        while (buf_len >= txt_box.width - 15) : (start += 1) {
            buf_len = @floatFromInt(rl.measureText(@ptrCast(input_txt.items[start..]), 20));
        }
        _ = input_txt.pop();
        break :b try alloc.dupeZ(u8, input_txt.items[start..]);
    };
    defer alloc.free(visible_input_buf);

    rl.drawText(
        visible_input_buf,
        @intFromFloat(txt_box.x + 5),
        @intFromFloat(txt_box.y + 8),
        20,
        if (new_valid) .dark_gray else .white
    );

    if ((state.frame_count / 20) % 2 == 0) rl.drawText(
        "_",
        @as(i32, @intFromFloat(txt_box.x)) + 8 + rl.measureText(visible_input_buf, 20),
        @intFromFloat(txt_box.y + 12),
        20,
        if (new_valid) .dark_gray else .white
    );
    return new_valid;
}

pub fn determine_random_direction() f32 {
    const rand = std.crypto.random;
    return
        if (rand.boolean())
            @floatFromInt(rl.getRandomValue(3, 5))
        else
            @floatFromInt(rl.getRandomValue(-5, 3));
}
