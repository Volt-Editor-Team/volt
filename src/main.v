module main

import cursor
import buffer
import util
import term.ui as tui
import term
import math

// import os
struct Viewport {
mut:
	row_offset int
	col_offset int
	height     int
	width      int
	margin     int
}

struct App {
mut:
	tui          &tui.Context = unsafe { nil }
	buffer       buffer.Buffer
	cursor       cursor.Cursor
	saved_cursor cursor.Cursor
	mode         util.Mode
	cmd_buffer   string
	viewport     Viewport
}

// attempted function to find first character
fn first_non_whitespace_index(line string) int {
	for i, ch in line {
		if !ch.is_space() {
			return i
		}
	}
	return line.len
}

fn event(e &tui.Event, x voidptr) {
	mut app := unsafe { &App(x) }

	mut line := app.buffer.lines[app.cursor.y].replace('\t', '    ')
	if e.typ == .key_down {
		match app.mode {
			.normal {
				match e.code {
					.l {
						app.cursor.move_right(app.buffer)
						app.cursor.visual_x = app.buffer.visual_x(app.cursor.y, app.cursor.x)
						app.cursor.desired_col = app.cursor.visual_x
						update_cursor(mut app)
					}
					.h {
						if app.cursor.x == 0 {
							if app.cursor.y > 0 {
								app.cursor.y -= 1
								app.cursor.x = app.buffer.lines[app.cursor.y].len
							}
						} else {
							app.cursor.x -= 1
						}
						app.cursor.visual_x = app.buffer.visual_x(app.cursor.y, app.cursor.x)
						app.cursor.desired_col = app.cursor.visual_x
						update_cursor(mut app)
					}
					.j {
						if app.cursor.y < app.buffer.lines.len - 1 {
							app.cursor.y += 1
							app.cursor.x = app.buffer.logical_x(app.cursor.y, app.cursor.desired_col)
							if app.cursor.y >= app.viewport.row_offset + app.viewport.height - app.viewport.margin {
								app.viewport.row_offset += 1
								app.tui.reset()
							}
						} else {
							app.cursor.x = app.buffer.lines[app.cursor.y].len
						}
						app.cursor.visual_x = app.buffer.visual_x(app.cursor.y, app.cursor.x)
						update_cursor(mut app)
					}
					.k {
						if app.cursor.y > 0 {
							app.cursor.y -= 1
							app.cursor.x = app.buffer.logical_x(app.cursor.y, app.cursor.desired_col)
							if app.viewport.row_offset > 0
								&& app.cursor.y <= app.viewport.row_offset + app.viewport.margin {
								app.viewport.row_offset -= 1
								app.tui.reset()
							}
						} else if app.cursor.y == 0 {
							app.cursor.x = 0
						}
						app.cursor.visual_x = app.buffer.visual_x(app.cursor.y, app.cursor.x)
						update_cursor(mut app)
					}
					.i {
						app.mode = .insert
					}
					.colon {
						app.saved_cursor = app.cursor
						app.mode = .command
					}
					else {}
				}
			}
			.insert {
				match e.code {
					.escape {
						app.mode = .normal
					}
					.backspace {
						line = line[..app.cursor.x - 1] + line[app.cursor.x..]
						app.buffer.lines[app.cursor.y] = line
						app.cursor.x -= 1
						update_cursor(mut app)
					}
					.enter {
						cur_line := app.buffer.lines[app.cursor.y].replace('\t', '    ')

						left := cur_line[..app.cursor.x]
						right := cur_line[app.cursor.x..]

						app.buffer.lines[app.cursor.y] = left

						app.buffer.lines.insert(app.cursor.y + 1, right)
						app.cursor.y += 1
						app.cursor.x = 0
					}
					else {
						line = line[..app.cursor.x] + e.ascii.ascii_str() + line[app.cursor.x..]
						app.buffer.lines[app.cursor.y] = line
						app.cursor.x += 1
						update_cursor(mut app)
					}
				}
			}
			.command {
				match e.code {
					.enter {
						match app.cmd_buffer {
							'q' {
								app.cmd_buffer = ''
								exit(0)
							}
							else {}
						}
					}
					.escape {
						app.mode = .normal
						app.cursor = app.saved_cursor
						app.cmd_buffer = ''
					}
					.backspace {
						before := app.cmd_buffer[..app.cursor.x - 2]
						after := app.cmd_buffer[app.cursor.x - 1..]
						app.cmd_buffer = before + after
						update_cursor(mut app)
					}
					else {
						ch := e.ascii.ascii_str()
						app.cmd_buffer += ch
						update_cursor(mut app)
					}
				}
			}
		}
	}
}

fn update_cursor(mut app App) {
	match app.mode {
		.command {
			app.tui.set_cursor_position(app.cursor.x + 1, app.cursor.y + 1)
		}
		else {
			app.tui.set_cursor_position(app.cursor.visual_x + 1, app.cursor.y + 1 - app.viewport.row_offset)
		}
	}
	app.tui.flush()
}

fn frame(x voidptr) {
	// get app pointer, terminal size, and clear to prep for updates
	mut app := unsafe { &App(x) }
	width, height := term.get_terminal_size()
	app.tui.clear()

	// initialize variables to simplify loop
	start_row := app.viewport.row_offset
	end_row := math.min(app.buffer.lines.len, app.viewport.row_offset + app.viewport.height)

	// tabsize := app.buffer.tabsize

	// render all visual lines
	// render all tabs as 4 spaces
	for i, line in app.buffer.lines[start_row..end_row] {
		visual_line := app.buffer.col_cache[start_row + i]
		for j, ch in line.runes() {
			mut col := visual_line[j] // visual column from cache
			app.tui.draw_text(col + 1, i + 1, ch.str())
		}
	}

	// app.tui.horizontal_separator(height - 2)
	app.tui.set_bg_color(util.deep_indigo)
	app.tui.draw_line(0, height - 1, width - 1, height - 1)

	command_str := util.mode_str(app.mode)

	app.tui.set_bg_color(util.get_command_bg_color(app.mode))

	app.tui.draw_line(4, height - 1, command_str.len + 1 + 4, height - 1)

	app.tui.draw_text(5, height - 1, term.bold(command_str))

	app.tui.set_bg_color(util.deep_indigo)

	app.tui.draw_text(command_str.len + 5 + 2, height - 1, './src/main.v')
	app.tui.draw_text(width - 5, height - 1, app.cursor.x.str() + ':' + app.cursor.y.str())

	app.tui.reset_bg_color()

	// debugging
	app.tui.draw_text(width - 30, height - 5, 'x: ' + app.cursor.x.str())
	app.tui.draw_text(width - 30, height - 4, 'viewport start: ' + app.viewport.row_offset.str())
	app.tui.draw_text(width - 30, height - 3, 'viewport end: ' + (app.viewport.row_offset +
		app.viewport.height).str())
	app.tui.draw_text(width - 30, height - 2, 'desired col: ' + app.cursor.desired_col.str())
	if app.mode == util.Mode.command {
		app.cursor.x = app.cmd_buffer.len + 1
		app.cursor.y = height

		// app.tui.set_cursor_position(app.cmd_buffer.len + 1, height)
		app.tui.draw_text(0, app.cursor.y, ':')
		app.tui.draw_text(2, app.cursor.y, app.cmd_buffer)

		// app.tui.flush()
	}

	app.tui.reset()

	update_cursor(mut app)
}

fn main() {
	width, height := term.get_terminal_size()
	file_path := './src/main.v'

	mut app := &App{
		buffer:   buffer.Buffer.new(file_path, 4)
		cursor:   cursor.Cursor{
			x:           0
			y:           0
			visual_x:    0
			desired_col: 0
		}
		mode:     util.Mode.normal
		viewport: Viewport{
			row_offset: 0
			col_offset: 0
			height:     height - 2
			width:      width
			margin:     5
		}
	}

	app.tui = tui.init(
		user_data:   app
		event_fn:    event
		frame_fn:    frame
		hide_cursor: false
	)

	app.tui.run()!
}
