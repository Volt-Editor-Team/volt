module list

import cursor { LogicalCursor, VisualCursor }
import fs { read_file }
import util { Mode, PersistantMode }
import buffer.common { InsertValue }

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
	// visual_cursor  VisualCursor
	saved_cursor   LogicalCursor
	row_offset     int

	// temp stuff
	file_ch chan string

	// cache visual col indexes
	// visual_col [][]int
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
		// visual_col: [][]int{len: lines.len}
		mode:       b.mode
		p_mode:     b.p_mode
	}

	// buf.update_all_line_cache()

	return buf
}

struct DeleteResult {
pub mut:
	joined_line bool
	new_x       int
}

// --- buffer interface ---
// - [ ] insert(cursor int, s InsertValue)
// - [ ] delete(cursor int, n int)
// - [ ] to_string() string
// - [x] len() int
// - [x] line_count() int
// - [x] line_at(i int)
// - [ ] char_at(i int) rune
// - [ ] slice(start int, end int) string
// - [ ] index_to_line_col(i int) (int, int)
// - [ ] line_col_to_index(line int, col int) int


pub fn (mut buf ListBuffer) insert(curs int, s InsertValue) !{
}

pub fn (mut buf ListBuffer) delete(curs int, n int) !{

}
pub fn (buf ListBuffer) to_string() string {
	return buf.lines.join('\n')
}
pub fn (buf ListBuffer) len() int {
	mut res := 0
	for line in buf.lines {
		res += line.runes().len
	}
	return res
}
pub fn (buf ListBuffer) line_count() int {
	return buf.lines.len

}
pub fn (buf ListBuffer) line_at(i int) string {
	return buf.lines[i]
}
pub fn (buf ListBuffer) char_at(i int) rune {
	return rune(` `)
}
pub fn (buf ListBuffer) slice(start int, end int) string {
	return ''
}
pub fn (buf ListBuffer) index_to_line_col(i int) (int, int) {
	return 1,1
}
pub fn (buf ListBuffer) line_col_to_index(line int, col int) int {
	return 0
}



