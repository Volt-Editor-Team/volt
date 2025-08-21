module buffer

import os

pub struct Buffer {
pub mut:
	// lines contains all lines of the text buffer.
	lines []string

	// cache visual col indexes
	visual_col [][]int
pub:
	tabsize int
}

pub fn Buffer.new(file_path string, tabsize int) Buffer {
	lines := (os.read_file(file_path) or { '' }).split_into_lines()
	mut buf := Buffer{
		lines:      lines
		tabsize:    tabsize
		visual_col: [][]int{len: lines.len}
	}

	for i in 0 .. buf.lines.len {
		buf.update_line_cache(i)
	}

	return buf
}
