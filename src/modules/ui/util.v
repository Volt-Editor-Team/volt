module ui

import term

pub fn get_terminal_size() (int, int) {
	return term.get_terminal_size()
}
