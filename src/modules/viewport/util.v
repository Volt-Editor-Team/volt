module viewport

import math
import buffer.common { BufferInterface }

pub fn (mut view Viewport) update_visual_wraps(x int) {
	view.visual_wraps = x
}

pub fn (mut view Viewport) fill_visible_lines(buf BufferInterface) {
}

// pub fn (mut view Viewport) update_offset(y_pos int) {
// 	// Compute the cursor's relative position inside the viewport
// 	rel_pos := y_pos - view.row_offset + view.visual_wraps

// 	// Check if cursor is past the bottom margin
// 	if rel_pos >= view.height - view.margin {
// 		// Scroll so the cursor is `margin` lines from the bottom
// 		view.row_offset = y_pos + view.visual_wraps - (view.height - view.margin) + 1
// 	}
// 	// Check if cursor is above the top margin
// 	else if y_pos - view.row_offset + view.visual_wraps <= view.margin {
// 		// Scroll so the cursor is `margin` lines from the top
// 		view.row_offset = math.max(0, y_pos + view.visual_wraps - view.margin)
// 	}
// }
pub fn (mut view Viewport) update_offset(y_pos int) {
	rel_pos := y_pos - view.row_offset + view.visual_wraps

	// Scroll down if cursor is below bottom margin
	if rel_pos >= view.height - view.margin {
		view.row_offset = y_pos + view.visual_wraps - (view.height - view.margin - 1)
	}
	// Scroll up if cursor is above top margin
	else if rel_pos < view.margin {
		view.row_offset = math.max(0, y_pos + view.visual_wraps - view.margin)
	}
}
