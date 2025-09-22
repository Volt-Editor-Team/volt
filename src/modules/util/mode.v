module util

import colors
import term.ui as tui

pub enum BufferFlag {
	directory
}

const secondary_class_modes = {
	Mode.command: true
}

pub enum Mode {
	insert
	normal
	command
	directory
}

pub fn mode_str(m Mode) string {
	return match m {
		.insert { 'INSERT' }
		.normal { 'NORMAL' }
		.command { 'COMMAND' }
		.directory { 'DIRECTORY' }
	}
}

pub fn get_command_bg_color(m Mode) tui.Color {
	return match m {
		.normal { colors.neutral_grey }
		.insert { colors.teal }
		.command { colors.amber }
		.directory { colors.neutral_grey }
	}
}

// pub fn change_modes(prev_m Mode, cur_m Mode, target Mode) (Mode, Mode) {
// 	if prev_m in secondary_class_modes {
// 		return cur_m, Mode.normal
// 	}
// 	return cur_m, target
// }
