module util

import constants
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
		.normal { constants.neutral_grey }
		.insert { constants.teal }
		.command { constants.amber }
	}
}
