module buffer

import cursor { LogicalCursor, VisualCursor }
import fs { read_file }
import util { Mode, PersistantMode }

pub struct Buffer {
pub mut:
	label  string
	name   string
	path   string = 'Scratch'
	mode   Mode
	p_mode PersistantMode

	// lines contains all lines of the text buffer.
	lines          []string = ['']
	logical_cursor LogicalCursor
	visual_cursor  VisualCursor
	saved_cursor   LogicalCursor
	row_offset     int
	// temp stuff
	temp_label  string
	temp_data   []string = []
	temp_cursor LogicalCursor
	temp_mode   PersistantMode
	temp_path   string

	// cache visual col indexes
	visual_col [][]int
pub:
	tabsize int
}

pub fn Buffer.new(b Buffer) Buffer {
	lines := read_file(b.path) or { b.lines }
	mut buf := Buffer{
		label:      if b.label.len == 0 { b.name } else { b.label }
		name:       b.name
		path:       b.path
		lines:      lines
		tabsize:    b.tabsize
		visual_col: [][]int{len: lines.len}
		mode:       b.mode
		p_mode:     b.p_mode
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
