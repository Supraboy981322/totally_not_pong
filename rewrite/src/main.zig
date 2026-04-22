const std = @import("std");
const rl = @import("raylib");
const hlp = @import("helpers.zig");
const player = @import("player.zig");
const PlayerSet = player.PlayerSet;
const Player = player.Player;
const Ball = @import("ball.zig").Ball;
const types = @import("types.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();
    
    rl.initWindow(800, 450, "totally not pong (100%)");
    defer rl.closeWindow();

    // WARNING: DO NOT REMOVE THIS (for now)
    // on my particular Hyprland install (NixOS + Nvidia + scrolling)
    //  window launches on wrong monitor and Hyprland thinks it's on the
    //    primary monitor, so if you don't move the window before attempting
    //      to change windows, Hyprland crashes entirely
    if (rl.getMonitorCount() > 1)
        rl.setWindowMonitor(1);
    
    rl.setTargetFPS(60);

    var ball:Ball = .init(14);

    var player_set:PlayerSet = .init(
        .init(15, 50, false, .left, &ball),
        .init(15, 50, true, .right, &ball)
    );

    var state:types.State = .init();
    state.aux_arraylist = try .initCapacity(alloc, 0);
    defer state.aux_arraylist.deinit(alloc);

    rl.setExitKey(.null);
    loop: while (!rl.windowShouldClose()) : (if (state.start_ok) try state.tick()) {
        if (hlp.is_ctrl_down() and rl.isKeyDown(.c))
            break :loop;

        if (!state.start_ok) {
            try render_menu(&state, alloc);
            continue;
        }

        if (rl.isKeyDown(.escape)) {
            state.is_paused = state.is_paused;
        }

        if (state.is_paused) {
            rl.beginDrawing();
            defer rl.endDrawing();
            rl.clearBackground(.dark_gray);
            const msgs = [_][:0]const u8{
                "game paused.",
                "press escape to unpause, or ctrl+c to quit",
            };
            for (msgs, 0..) |line, i| {
                const txt_width = rl.measureText(
                    line,
                    30,
                );
                const v_offset:i32 = @intCast(30 + (50 * (msgs.len - i - 1)));
                rl.drawText(
                    line,
                    @divTrunc((rl.getScreenWidth() - txt_width), 2),
                    @divTrunc(rl.getScreenHeight() - v_offset, 2),
                    30,
                    .white,
                );
            }
            rl.pollInputEvents();
            if (rl.isKeyReleased(.escape)) state.toggle_pause();
            continue;
        }

        const touching_side = ball.tick(player_set);
        if (touching_side) |side| {
            if (side == .left)
                player_set.p2.points += 1
            else
                player_set.p1.points += 1;
        }
        player_set.p1.tick();
        player_set.p2.tick();

        rl.beginDrawing();
        defer rl.endDrawing();
        rl.clearBackground(.black);

        ball.draw();
        player_set.p1.draw();
        player_set.p2.draw();
        try state.draw(player_set);
    }
}

pub fn render_menu(state:*types.State, alloc:std.mem.Allocator) !void {
    rl.beginDrawing();
    defer rl.endDrawing();

    switch (state.menu) {
        .start => {
            draw_start_menu(state);
            if (rl.isKeyDown(.enter))
                state.menu = .match_opts;
        },
        .match_opts => try draw_match_opts(state, alloc),
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

    const goal_elem_y_pos:f32 = @divFloor(@as(f32, @floatFromInt(rl.getScreenHeight() - 35 + 20)), 2);
    const goal_elem_title = "goal (number of points to win)";
    rl.drawText(
        goal_elem_title,
        @divTrunc(rl.getScreenWidth() - rl.measureText(goal_elem_title, 20), 2),
        @intFromFloat(goal_elem_y_pos - 10),
        20,
        .white
    );
    try hlp.input_box(state, alloc, goal_elem_y_pos + 35);
}
