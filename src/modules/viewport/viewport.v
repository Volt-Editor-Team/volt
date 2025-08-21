module viewport

// Attempts to update viewport display based on cursors row position
//
// Returns true if change is made to viewport offset, otherwise returns false
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
