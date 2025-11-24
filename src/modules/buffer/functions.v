module buffer

import cursor { LogicalCursor }
import util

pub fn (mut buf Buffer) move_right(vp ?[][]rune, tabsize int) {
	// buf.logical_cursor.move_right_buffer(mut buf.cur_line, tabsize)
}

pub fn (mut buf Buffer) delete(num_char int) {
	buf.buffer.delete(buf.logical_cursor.flat_index, num_char) or { return }
	buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
}

pub fn (mut buf Buffer) clear_all_temp_data() {
	buf.temp_label = ''
	buf.temp_string = ''
	buf.temp_data = [][]rune{}
	buf.temp_list = []string{}
	buf.temp_int = 0
	buf.temp_cursor = LogicalCursor{}
	buf.temp_mode = .default
	buf.temp_path = ''
	buf.temp_fuzzy_type = .file
}

pub fn (mut buf Buffer) change_mode(mode util.Mode, with_menu bool) {
	if mode == .command {
		// buf.saved_cursor = buf.logical_cursor
		buf.cmd.command = ': '
		buf.prev_mode = buf.mode
		buf.mode = mode
	} else if buf.prev_mode == .command {
		// buf.logical_cursor = buf.saved_cursor
		buf.cmd.command = ''
		if buf.prev_mode == .insert {
			buf.mode = .insert
		} else {
			buf.mode = .normal
		}
	} else {
		buf.prev_mode = buf.mode
		buf.mode = mode
	}
	buf.menu_state = with_menu
}
