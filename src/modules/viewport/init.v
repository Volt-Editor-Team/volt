module viewport

import cursor { LogicalCursor }

pub struct Viewport {
pub mut:
	col_offset           int
	line_num_to_text_gap int
	height               int
	width                int
	visual_wraps         int

	row_offset       int
	existing_offsets map[int]int
	visible_lines    [][]rune
	line_wraps       []int
	cursor           LogicalCursor
	existing_cursors map[int]LogicalCursor
	tabsize          int
pub:
	margin int
}
