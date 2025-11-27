module buffer

import cursor { LogicalCursor }
import util
import math

pub fn (mut buf Buffer) move_right(vp ?[][]rune, tabsize int) {
	// buf.logical_cursor.move_right_buffer(mut buf.cur_line, tabsize)
}

pub fn (mut buf Buffer) delete(pos int, num_char int) {
	// buf.buffer.delete(buf.logical_cursor.flat_index, num_char) or { return }
	buf.buffer.delete(pos, num_char) or { return }
	// buf.cur_line = buf.buffer.line_at(buf.logical_cursor.y)
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
	// changing from command mode
	if buf.prev_mode == .command {
		buf.cmd.command = ''
	}

	buf.prev_mode = buf.mode
	if mode == .command {
		buf.cmd.command = ': '
	}
	buf.mode = mode

	if buf.p_mode == .fuzzy {
		buf.temp_cursor.y = math.min(buf.temp_data.len - 1, buf.temp_cursor.y)
	}
	buf.menu_state = with_menu
}
