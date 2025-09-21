module viewport

pub struct Viewport {
pub mut:
	col_offset           int
	line_num_to_text_gap int
	height               int
	width                int
	visual_wraps         int
pub:
	margin int
}
