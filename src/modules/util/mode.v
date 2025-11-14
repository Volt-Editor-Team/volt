module util

import colors
import term.ui as tui

pub struct StopFlag {
pub mut:
	flag bool
}

pub enum BufferFlag {
	directory
}

const secondary_class_modes = {
	Mode.command: true
}

pub enum PersistantMode {
	default
	directory
	fuzzy
}

pub enum Mode {
	insert
	normal
	command
	menu
	goto
	search
}

pub fn mode_str(m Mode, pm PersistantMode) string {
	return match m {
		.insert {
			'INSERT'
		}
		.normal {
			match pm {
				.directory { 'DIRECTORY' }
				.fuzzy { 'FUZZY' }
				else { 'NORMAL' }
			}
		}
		.command {
			'COMMAND'
		}
		.menu {
			'MENU'
		}
		.goto {
			'GOTO'
		}
		.search {
			'SEARCH'
		}
	}
}

pub fn get_command_bg_color(m Mode, pm PersistantMode) tui.Color {
	return match m {
		.normal {
			match pm {
				.directory { colors.neutral_grey }
				.fuzzy { colors.neutral_grey }
				else { colors.neutral_grey }
			}
		}
		.insert {
			colors.teal
		}
		.command {
			colors.amber
		}
		.menu {
			colors.neutral_grey
		}
		.goto {
			colors.neutral_grey
		}
		.search {
			colors.neutral_grey
		}
	}
}
