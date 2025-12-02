module events

// -- insertion --
import buffer
import viewport

// insert_one inserts one rune at the cursors position
// and moves the cursor forward one visual position
pub fn insert_one(mut buf buffer.Buffer, mut view viewport.Viewport, ch rune) {
	buf.buffer.insert(view.cursor.flat_index, ch) or { return }
	updated_line := buf.buffer.line_at(view.cursor.y).clone()
	view.visible_lines[view.cursor.y - view.row_offset] = updated_line

	// view.cursor.move_right_buffer(mut buf.cur_line, buf.buffer, mut
	// 	view.visible_lines, view.tabsize)
	view.cursor.move_right_buffer(view.visible_lines, view.row_offset, view.tabsize)
	view.cursor.update_desired_col(view.width)
}

// insert_many inserts a list of runes at the position of the cursor
// and moves the cursor forward the visual total length of the runes
pub fn insert_many(mut buf buffer.Buffer, mut view viewport.Viewport, runes []rune) {
	relative_y := view.cursor.y - view.row_offset
	// edit buffer data
	buf.buffer.insert(view.cursor.flat_index, runes) or { return }

	// update visible lines
	updated_line := buf.buffer.line_at(view.cursor.y).clone()
	view.visible_lines[relative_y] = updated_line
	next_line := buf.buffer.line_at(view.cursor.y + 1).clone()
	view.visible_lines.insert(relative_y + 1, next_line)

	// clamp visible buffer if it contains more than viewable lines
	if view.visible_lines.len >= view.height
		&& view.visible_lines.len + view.row_offset < buf.buffer.line_count() {
		view.visible_lines.delete_last()
	}

	// move cursor
	view.cursor.move_to_x_next_line_buffer(runes.len - 1, view.visible_lines, view.row_offset,
		view.tabsize)

	// update viewport offset
	view.update_offset(buf.buffer)

	// update desired column
	view.cursor.update_desired_col(view.width)
}
