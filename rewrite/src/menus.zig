const std = @import("std");
const rl = @import("raylib");
const rg = @import("raygui");
const hlp = @import("helpers.zig");
const types = @import("types.zig");

const PlayerSet = @import("player.zig").PlayerSet;

pub fn render_menu(state:*types.State, alloc:std.mem.Allocator) !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    switch (state.menu) {
        .start => {
            draw_start_menu(state);
            if (rl.isKeyDown(.enter)) {
                state.menu = .match_opts;
                while (rl.isKeyDown(.enter)) : (rl.pollInputEvents()) {}
            }
        },
        .match_opts => try draw_match_opts(state, alloc),
        else => unreachable,
    }
}

pub fn draw_start_menu(_:*types.State) void {
    rl.clearBackground(.black);

    const title = "totally not pong (100%)";
    const titleWidth = rl.measureText(title, 35);
    rl.drawText(
        title,
        @divTrunc(rl.getScreenWidth() - titleWidth, 2),
        @divTrunc(rl.getScreenHeight(), 2) - 45,
        35,
        .sky_blue,
    );

    const start_txt:[:0]const u8 = "press enter to start";
    const start_txt_width = rl.measureText(start_txt, 30);
    
    rl.drawText(
        start_txt,
        @divTrunc(rl.getScreenWidth() - start_txt_width, 2),
        @divTrunc(rl.getScreenHeight(), 2) + 25,
        30,
        .ray_white,
    );

    const quit_txt:[:0]const u8 = "(press ctrl+c to quit)";
    const quit_txt_width = rl.measureText(quit_txt, 26);
    rl.drawText(
        quit_txt,
        @divTrunc(rl.getScreenWidth() - quit_txt_width, 2),
        @divTrunc(rl.getScreenHeight(), 2) + 25 + 41,
        26,
        .ray_white,
    );
}

pub fn draw_match_opts(state:*types.State, alloc:std.mem.Allocator) !void {
    const gap = rl.measureText("ab", 20) - (rl.measureText("a", 20) + rl.measureText("b", 20));

    rl.clearBackground(.black);

    const title = "match options";
    const titleWidth = rl.measureText(title, 30);
    rl.drawText(
        title,
        @divTrunc(rl.getScreenWidth() - titleWidth, 2),
        50,
        30,
        .gold,
    );

    var stage:enum {
        goal,
        done,
    } = @enumFromInt(state.aux.num);
    defer state.aux.num = @intFromEnum(stage);

    switch (stage) {
        .goal => {
            const goal_elem_y_pos:f32 = @divFloor(state.screen.height_f32 - 35 + 20, 2);
            const goal_elem_title = "goal (number of points to win) (defaults to 10)";

            const first_half:[:0]const u8 = @constCast(goal_elem_title[0..6]) ++ "\x00";
            const second_half:[:0]const u8 = @constCast(goal_elem_title[12..]) ++ "\x00";
            const middle:[:0]const u8 = b: {
                const end = goal_elem_title.len - second_half.len + 1;
                break :b @constCast(goal_elem_title[first_half.len-1 .. end]) ++ "\x00";
            };

            const first_half_len = rl.measureText(first_half, 20);
            const middle_len = rl.measureText(middle, 20);

            state.aux.unum = state.aux.arraylist.items.len;
            state.aux.boolean =
                try hlp.input_box(
                    state,
                    alloc,
                    goal_elem_y_pos + 35,
                    state.aux.boolean,
                    &std.ascii.isDigit
                );

            if (rl.isKeyDown(.enter)) {
                while (rl.isKeyDown(.enter)) : (rl.pollInputEvents()) {}
                if (state.aux.arraylist.items.len == 0)
                    try state.aux.arraylist.appendSlice(alloc, "10");
                state.opts.goal = std.fmt.parseInt(
                    usize, state.aux.arraylist.items, 10
                ) catch unreachable; //user input already validated
                state.aux.arraylist.clearAndFree(alloc);
                stage = .done;
                return;
            }

            const title_real_len = rl.measureText(goal_elem_title, 20);
            var offset:i32 = @divTrunc(rl.getScreenWidth() - title_real_len, 2);
            rl.drawText(
                first_half,
                offset,
                @intFromFloat(goal_elem_y_pos - 10),
                20,
                .white,
            );
            offset += first_half_len + gap;
            rl.drawText(
                middle,
                offset,
                @intFromFloat(goal_elem_y_pos - 10),
                20,
                if (state.aux.boolean) .gold else .red,
            );
            offset += middle_len + gap;
            rl.drawText(
                second_half,
                offset,
                @intFromFloat(goal_elem_y_pos - 10),
                20,
                .white,
            );
        },
        .done => state.menu = .in_game,
        //else => unreachable, //invalid state.aux.num for match_opts
    }
}

pub fn render_win(state:*types.State, alloc:std.mem.Allocator, player_set:PlayerSet) !void {
    _ = .{ state, alloc, player_set };
    rl.beginDrawing();
    defer rl.endDrawing();
    rl.clearBackground(.black);
    const winner =
        if (player_set.p1.points > player_set.p2.points)
            player_set.p1
        else
            player_set.p2;
    var msg:[:0]u8 = @constCast("winner: player \x00" ++ "\x00");
    msg[msg.len - 2] = if (winner.side == .left) '1' else '2';
    rl.drawText(
        @constCast(msg),
        @divFloor(rl.getScreenWidth() - rl.measureText(msg, 30), 2),
        @divFloor(rl.getScreenHeight() - 15, 2),
        30,
        .gold,
    );
}
