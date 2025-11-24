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
	visible_lines    [][]rune
	line_wraps       []int
	logical_cursor   LogicalCursor
	existing_cursors []LogicalCursor
	tabsize          int
pub:
	margin int
}
