module tui

import viewport { Viewport }
import buffer { Buffer }
import util
import util.colors
import util.constants
import os
import math

fn (mut tui_app TuiApp) draw_default_content(buf Buffer, mut view Viewport, multiple_buffers bool) {
	mut ctx := tui_app.tui

	start_row := view.row_offset
	end_row := math.min(buf.buffer.line_count(), view.row_offset + view.height)
	buffer_gap := int(multiple_buffers)

	// TODO: directory buffer will likely needs its own function
	line_count := buf.buffer.line_count()
	mut width := if line_count < 10 { 1 }
	    else if line_count < 100 { 2 }
	    else if line_count < 1000 { 3 }
	    else if line_count < 10000 { 4 }
	    else { 5 }
	allocated_line_num_width := if buf.p_mode == .default { width } else { 1 }


	// render loop
	mut wrap_offset := 0
	mut wraps := 0
	render_lines: for i in 0 .. end_row - start_row {
		wraps = 0
		// i is the row index of the actual renders screen
		// y_index is the position in the buffer
		y_index := start_row + i
		// line := buf.buffer.line_at(y_index)
		line := if view.visible_lines.len > 0 { view.visible_lines[i] } else { [] }

		// values necessary for rendering aligned line numbers

		// determine cursor colors
		cursor_bg_color, cursor_fg_color := ctx.get_cursor_colors(buf.mode, tui_app.theme)

		// get line indices and characters
		line_num_label, text_color, line_num_active_color, line_num_inactive_color := ctx.get_gutter_label_and_colors(buf.path,
			line, y_index, allocated_line_num_width, buf.p_mode, tui_app.theme)

		// highlight active line and render line numbers
		// this is rendered first, simulating line highlight over active line
		if y_index == view.cursor.y {
			// calculate how many lines that this line requires
			// (+ 1 since base is 0)
			total_lines := if line.len > 0 {
				(util.char_count_expanded_tabs(line, view.tabsize) / view.width) + 1
			} else {
				1
			}
			ctx.set_colors(tui_app.theme.active_line_bg_color, line_num_active_color)
			for wrap in 0 .. total_lines {
				active_line_index := i + wrap + wrap_offset + buffer_gap + 1
				if active_line_index > view.height {
					ctx.reset_colors()
					break render_lines
				}
				// not sure why +3 on end x
				ctx.draw_line(0, active_line_index, view.width - 1, active_line_index)
				ctx.draw_text(view.col_offset, i + wrap_offset + buffer_gap + 1,
					line_num_label)
			}
			ctx.reset_colors()
		} else {
			if i + wrap_offset + 1 > view.height {
				break render_lines
			}
			// render just line number for inactive line
			ctx.set_colors(tui_app.theme.background_color, line_num_inactive_color)
			ctx.draw_text(view.col_offset, i + wrap_offset + buffer_gap + 1, line_num_label)
			ctx.reset_colors()
		}

		mut char_width := 1
		mut visual_cache := map[int]int{}
		mut col := 0
		for x_index, ch in line {
			visual_cache[x_index] = col
			mut printed := ch
			if ch == `\t` {
				printed = ` `
				char_width = view.tabsize
				col += view.tabsize - (col % view.tabsize)
			} else {
				col++
			}
			visual_x_index := visual_cache[x_index]
			wraps = visual_x_index / view.width
			x_pos := visual_x_index % view.width + view.col_offset +
				allocated_line_num_width + 1
			y_pos := i + wraps + wrap_offset + buffer_gap

			if y_pos > view.height - buffer_gap {
				break render_lines
			}

			if x_index == view.cursor.x && y_index == view.cursor.y {
				view.visual_wraps = wrap_offset
				ctx.set_colors(cursor_bg_color, cursor_fg_color)
				ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
				ctx.reset_colors()
			} else if y_index == view.cursor.y {
				ctx.set_colors(tui_app.theme.active_line_bg_color, text_color)
				ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
				ctx.reset_colors()
			} else {
				ctx.set_colors(tui_app.theme.background_color, text_color)
				ctx.draw_text(x_pos + 1, y_pos + 1, printed.str().repeat(char_width))
				ctx.reset_colors()
			}
			char_width = 1
		}

		// Special case: cursor at end of line
		if view.cursor.y == y_index && view.cursor.x == line.len {
			// find last column in this line (or 0 if empty)
			// last_index := line[line.len - 1]
			last_x := if line.len > 0 {
				// visual_cache[line.len - 1] + char_width
				col
			} else {
				0
			}
			last_wraps := if line.len > 0 { last_x / view.width } else { 0 }
			cursor_x := last_x % view.width + view.col_offset + allocated_line_num_width + 1
			cursor_y := i + last_wraps + wrap_offset + buffer_gap
			if cursor_y > view.height - buffer_gap {
				break render_lines
			}

			view.visual_wraps = wrap_offset
			ctx.set_colors(cursor_bg_color, cursor_fg_color)
			ctx.draw_text(cursor_x + 1, cursor_y + 1, ' ') // or just draw a block cursor
			ctx.reset_colors()
		}

		wrap_offset += wraps
	}
}

fn (mut tui_app TuiApp) draw_fuzzy_content(buf Buffer, view Viewport, multiple_buffers bool) {
	mut ctx := tui_app.tui

	buffer_gap := int(multiple_buffers)
	start_row := view.row_offset
	allocated_line_num_width := 1
	end_row := math.min(buf.temp_data.len, view.row_offset + view.height)

	// draw for fuzzy
	// draw input line
	mut start := 1 + buffer_gap
	first_line := start
	input_string := '> ${buf.temp_label}'
	ctx.set_bg_color(tui_app.theme.background_color)
	ctx.draw_text(1, start, input_string)
	file_count_text := '( walked: ${buf.temp_data.len} / ${buf.temp_int} )'
	ctx.draw_text(view.width - file_count_text.len - 2, first_line, file_count_text)

	start_x := allocated_line_num_width + 2

	start++ // increment to draw after input line

	// draw selections
	ctx.set_color(colors.deep_indigo)
	for i, selected in buf.temp_list {
		selected_path := selected.replace(buf.temp_path + os.path_separator, '')
		file_ext := os.file_ext(selected)
		if file_ext in constants.ext_icons {
			filetype := constants.ext_icons[file_ext]
			fg_color := colors.hex_to_tui_color(filetype.color) or { colors.white }
			line_num_label := filetype.icon +
				' '.repeat(allocated_line_num_width - filetype.icon.len)
			ctx.set_color(fg_color)
			ctx.draw_text(1, i + start, line_num_label)
			ctx.set_color(colors.deep_indigo)
		}

		ctx.draw_text(start_x, start + i, selected_path)
	}
	ctx.reset_color()
	start += buf.temp_list.len // increment to draw after selections
	if buf.mode == .insert {
		// draw the input string to match
		// the cursor is a lie but it looks good
		ctx.set_bg_color(tui_app.theme.insert_cursor_color)
		ctx.draw_text(input_string.len + 1, first_line, ' ')
		if buf.temp_data.len > 0 {
			ctx.set_bg_color(tui_app.theme.active_line_bg_color)
			ctx.draw_line(0, start, view.width - 1, start)
			ctx.draw_text(start_x, start, buf.temp_data[0].string())
		}
		ctx.set_bg_color(tui_app.theme.background_color)
	}
	// start -= buf.temp_list.len // increment to draw after selections

	// draw search results
	for i, line_runes in buf.temp_data#[start_row..end_row] {
		line := line_runes.string()
		y_index := i + start_row
		mut line_num_label := ' '.repeat(buf.temp_data.len.str().len)
		file_ext := os.file_ext(line)
		// highlight cursor line
		if (buf.mode != .insert && y_index == buf.temp_cursor.y)
			|| (buf.mode == .insert && i + start_row == 0) {
			ctx.set_bg_color(tui_app.theme.active_line_bg_color)
			ctx.draw_line(0, i + start, view.width - 1, i + start)
		} else {
			ctx.set_bg_color(tui_app.theme.background_color)
		}
		// draw icon if file
		// if not file, fill with spaces
		if file_ext in constants.ext_icons {
			filetype := constants.ext_icons[file_ext]
			fg_color := colors.hex_to_tui_color(filetype.color) or { colors.white }
			line_num_label = filetype.icon +
				' '.repeat(allocated_line_num_width - filetype.icon.len)
			if buf.mode == .insert && i == 0 {
				ctx.set_bg_color(tui_app.theme.active_line_bg_color)
			}
			ctx.set_color(fg_color)
			ctx.draw_text(1, i + start, line_num_label)
			ctx.reset_color()
		} else {
			line_num_label = ' '.repeat(allocated_line_num_width)
			ctx.draw_text(1, i + start, line_num_label)
		}
		// draw actual line characters
		for j, ch in line_runes {
			mut char_to_draw := ch.str()
			if buf.temp_label.to_lower().contains(ch.str().to_lower()) {
				ctx.set_color(colors.lavender_violet)
			}
			if buf.temp_list.contains(buf.temp_path + os.path_separator +
				line_runes.string())
			{
				ctx.set_color(colors.dark_red)
				if j == line_runes.len - 1 {
					char_to_draw += ' [ SELECTED ]'
				}
			}
			if buf.mode == .insert && i == 0 {
				ctx.set_bg_color(tui_app.theme.active_line_bg_color)
				ctx.draw_text(j + start_x, i + start, char_to_draw)
			} else {
				ctx.draw_text(j + start_x, i + start, char_to_draw)
			}
			ctx.reset_color()
		}
	}
}
