module events

// -- deletion --
import buffer
import viewport

pub fn delete_selection(mut buf buffer.Buffer, mut view viewport.Viewport, width int) {
	buf.delete(view.cursor.flat_index, width)
	updated_line := buf.buffer.line_at(view.cursor.y).clone()
	view.visible_lines[view.cursor.y - view.row_offset] = updated_line
}

pub fn delete_before(mut buf buffer.Buffer, mut view viewport.Viewport, width int) {
	total_lines := buf.buffer.line_count() // grab line_count to determine if a newline is deleted
	// take the previous lines length
	prev_line_len := if view.cursor.y > 0 {
		buf.buffer.line_at(view.cursor.y - 1).len
	} else {
		0
	}
	// delete the character before the cursor
	buf.buffer.delete(view.cursor.flat_index - 1, width) or { return }
	// a line was deleted
	if buf.buffer.line_count() != total_lines {
		// move cursor
		view.cursor.move_up_buffer(view.visible_lines, view.row_offset, view.tabsize)
		updated_line := buf.buffer.line_at(view.cursor.y).clone()
		view.cursor.move_to_x(updated_line, prev_line_len, view.tabsize)
		view.visible_lines[view.cursor.y - view.row_offset] = updated_line

		// delete merged line
		view.visible_lines.delete(view.cursor.y - view.row_offset + 1)

		// add new line from data
		next_line := buf.buffer.line_at(view.row_offset + view.visible_lines.len).clone()
		view.visible_lines << next_line
	}
	// no line was deleted
	else {
		if view.cursor.x > 0 {
			// move cursor
			view.cursor.move_to_x(buf.cur_line, view.cursor.x - 1, view.tabsize)
			// update current visible line
			updated_line := buf.buffer.line_at(view.cursor.y).clone()
			view.visible_lines[view.cursor.y - view.row_offset] = updated_line
		}
	}
	view.update_offset(buf.buffer)
	// view.fill_visible_lines(buf.buffer)
	view.cursor.update_desired_col(view.width)
}
