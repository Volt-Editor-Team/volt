module viewport

pub struct Viewport {
pub mut:
	row_offset           int
	col_offset           int
	line_num_to_text_gap int
	height               int
	width                int
pub:
	margin int
}
