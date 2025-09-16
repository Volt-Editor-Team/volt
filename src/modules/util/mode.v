module util

import colors
import term.ui as tui

pub enum Mode {
	insert
	normal
	command
}

pub fn mode_str(m Mode) string {
	return match m {
		.insert { 'INSERT' }
		.normal { 'NORMAL' }
		.command { 'COMMAND' }
	}
}

pub fn get_command_bg_color(m Mode) tui.Color {
	return match m {
		.normal { colors.neutral_grey }
		.insert { colors.teal }
		.command { colors.amber }
	}
}
