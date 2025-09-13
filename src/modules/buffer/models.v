module buffer

import fs { read_file }

pub struct Buffer {
pub mut:
	path string
	// lines contains all lines of the text buffer.
	lines []string

	// cache visual col indexes
	visual_col [][]int
pub:
	tabsize int
}

pub fn Buffer.new(file_path string, tabsize int) Buffer {
	lines := read_file(file_path) or { [''] }
	mut buf := Buffer{
		path:       file_path
		lines:      lines
		tabsize:    tabsize
		visual_col: [][]int{len: lines.len}
	}

	buf.update_all_line_cache()

	return buf
}

struct DeleteResult {
pub mut:
	joined_line bool
	new_x       int
}

pub struct CommandBuffer {
pub mut:
	command string
}
