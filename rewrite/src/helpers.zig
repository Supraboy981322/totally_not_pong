const rl = @import("raylib");

pub fn is_ctrl_down() bool {
    return rl.isKeyDown(.left_control) or rl.isKeyDown(.right_control);
}
