module buffer

import cursor { LogicalCursor, VisualCursor }
import fs { read_file }

pub struct Buffer {
pub mut:
	name string
	path string = 'Scratch'
	// lines contains all lines of the text buffer.
	lines          []string = ['']
	logical_cursor LogicalCursor
	visual_cursor  VisualCursor
	saved_cursor   LogicalCursor
	row_offset     int

	// cache visual col indexes
	visual_col [][]int

	is_directory_buffer bool
pub:
	tabsize int
}

pub fn Buffer.new(b Buffer) Buffer {
	lines := read_file(b.path) or { b.lines }
	mut buf := Buffer{
		name:                b.name
		path:                b.path
		lines:               lines
		tabsize:             b.tabsize
		visual_col:          [][]int{len: lines.len}
		is_directory_buffer: b.is_directory_buffer
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
