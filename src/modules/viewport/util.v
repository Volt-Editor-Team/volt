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
		view.visible_lines << buf.line_at(i).clone()
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
pub fn (mut view Viewport) update_offset(buf BufferInterface) {
	prev_offset := view.row_offset
	y_pos := view.cursor.y
	all_wraps := view.visual_wraps + (view.cursor.visual_x / (view.width - 1))
	rel_pos := y_pos - view.row_offset + all_wraps

	// Scroll down if cursor is below bottom margin
	if rel_pos >= view.height - view.margin {
		view.row_offset = y_pos + all_wraps - (view.height - view.margin - 1)
		offset_diff := math.min(view.row_offset - prev_offset, view.height)
		total_lines := buf.line_count()

		for i in 0 .. offset_diff {
			view.visible_lines.delete(0)
			if view.visible_lines.len < total_lines - view.row_offset {
				line_index := view.row_offset + view.height - (offset_diff + i)
				new_line := buf.line_at(line_index).clone()
				view.visible_lines << new_line
			}
		}
	}
	// Scroll up if cursor is above top margin
	else if rel_pos < view.margin {
		view.row_offset = math.max(0, y_pos + all_wraps - view.margin)
		offset_diff := math.min(prev_offset - view.row_offset, view.height)
		for i in 0 .. offset_diff {
			if view.visible_lines.len >= view.height {
				view.visible_lines.delete_last()
			}
			new_line := buf.line_at(view.row_offset + i).clone()
			view.visible_lines.prepend(new_line)
		}
	}
}

pub fn (mut view Viewport) update_offset_for_temp(y_pos int) {
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
