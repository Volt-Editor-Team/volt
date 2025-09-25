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
	}
}

// pub fn change_modes(prev_m Mode, cur_m Mode, target Mode) (Mode, Mode) {
// 	if prev_m in secondary_class_modes {
// 		return cur_m, Mode.normal
// 	}
// 	return cur_m, target
// }
