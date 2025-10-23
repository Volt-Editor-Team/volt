module list

import cursor { LogicalCursor, VisualCursor }
import fs { read_file }
import util { Mode, PersistantMode }

pub struct ListBuffer {
	TempData
pub mut:
	label  string         = 'Scratch'
	name   string         = 'Scratch'
	path   string         = 'Scratch'
	mode   Mode           = .normal
	p_mode PersistantMode = .default

	// lines contains all lines of the text buffer.
	lines          []string = ['']
	logical_cursor LogicalCursor
	visual_cursor  VisualCursor
	saved_cursor   LogicalCursor
	row_offset     int

	// temp stuff
	file_ch chan string

	// cache visual col indexes
	visual_col [][]int
pub:
	tabsize int
}

pub struct TempData {
pub mut:
	temp_label  string
	temp_data   []string = []
	temp_int    int
	temp_cursor LogicalCursor
	temp_mode   PersistantMode
	temp_path   string
}

pub fn ListBuffer.new(b ListBuffer) ListBuffer {
	lines := read_file(b.path) or { b.lines }
	mut buf := ListBuffer{
		label:      if b.label == 'Scratch' { b.name } else { b.label }
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
