module viewport

import math
import buffer.common { BufferInterface }

pub fn (mut view Viewport) update_visual_wraps(x int) {
	view.visual_wraps = x
}

pub fn (mut view Viewport) fill_visible_lines(buf BufferInterface) {
	view.visible_lines.clear()
	total_lines := buf.line_count()
	for i in view.row_offset .. view.row_offset + view.height {
		if i >= total_lines {
			break
		}
		view.visible_lines << buf.line_at(i)
	}
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
pub fn (mut view Viewport) update_offset(y_pos int, buf BufferInterface) {
	prev_offset := view.row_offset
	rel_pos := y_pos - view.row_offset + view.visual_wraps

	// Scroll down if cursor is below bottom margin
	if rel_pos >= view.height - view.margin {
		view.row_offset = y_pos + view.visual_wraps - (view.height - view.margin - 1)
		offset_diff := math.min(view.row_offset - prev_offset, view.height)

		for i in 0 .. offset_diff {
			if view.visible_lines.len >= view.height {
				view.visible_lines.delete(0)
			}
			line_index := view.row_offset + view.height - (offset_diff + i)
			view.visible_lines << buf.line_at(line_index)
		}
	}
	// Scroll up if cursor is above top margin
	else if rel_pos < view.margin {
		view.row_offset = math.max(0, y_pos + view.visual_wraps - view.margin)
		offset_diff := math.min(prev_offset - view.row_offset, view.height)
		for i in 0 .. offset_diff {
			if view.visible_lines.len >= view.height {
				view.visible_lines.delete_last()
			}
			view.visible_lines.prepend(buf.line_at(view.row_offset + i))
		}
	}
}
