module viewport

// Attempts to update viewport display based on cursors row position
//
// Returns true if change is made to viewport offset, otherwise returns false
pub fn (mut view Viewport) update_width() {
	view.width -= view.col_offset + view.line_num_to_text_gap
}

pub fn (mut view Viewport) update_offset(row_pos int) bool {
	if row_pos >= view.row_offset + view.height - view.margin {
		// increment viewport offset (starting index) if required
		view.row_offset += 1
		return true
	} else if view.row_offset > 0 && row_pos <= view.row_offset + view.margin {
		// decrement viewport offset (starting index) if required
		view.row_offset -= 1
		return true
	}
	return false
}

pub fn (mut view Viewport) build_wrap_points(line string) []int {
	if line.len == 0 {
		return [0]
	}
	mut wraps := []int{}
	for i := 0; i < line.len; i += view.width {
		wraps << i
	}
	return wraps
}

pub fn (mut view Viewport) get_wrapped_index(wrap_points []int, cur_index int) int {
	mut index := 0
	for wrap_points[index] < cur_index && index < wrap_points.len {
		index++
	}

	return index - 1
}
