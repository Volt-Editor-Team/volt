module tui

import core.controller

fn redraw_loop(x voidptr) {
	// get app pointer, terminal size, and clear to prep for updates
	mut tui_app := get_tui(x)
	mut ctx := tui_app.tui
	mut app := controller.get_app(tui_app.core)

	// relavent info for rendering
	mut view := &app.viewport
	mut buf := &app.buffers[app.active_buffer]

	buf.needs_render =
	    buf.needs_render ||
	    tui_app.rerender_viewport(mut view, buf.buffer) ||
	    (buf.p_mode == .fuzzy)

	// early exit if no render needed
	if !buf.needs_render {
		return
	}

	// --- draw background ---
	ctx.draw_background(1, 1, view.width, view.height, tui_app.theme.background_color)

	// --- draw tabs for multiple buffers ---
	multiple_buffers := app.buffers.len > 1
	// buffer_gap := int(multiple_buffers)
	if multiple_buffers {
		// buffer_names := []string{len: app.buffers.len, init: ' ' + app.buffers[index].name + ' '}
		// ctx.draw_tabs(buffer_names, app.active_buffer, view.width, tui_app.theme)
		ctx.draw_tabs(app.buffers, app.active_buffer, view.width, tui_app.theme)
	}


	// --- render content ---
	match buf.p_mode {
		.default {
			tui_app.draw_default_content(buf, mut view, multiple_buffers)
		}
		.directory {
			tui_app.draw_default_content(buf, mut view, multiple_buffers)
		}
		.fuzzy {
			tui_app.draw_fuzzy_content(buf, view, multiple_buffers)
		}
	}
	// -- debugging --
	// if view.visible_lines.len > 0 {
	// ctx.draw_text(view.width - 90,view.height - 6, buf.buffer.line_at(view.cursor.y).str())
	// 	ctx.draw_text(view.width - 90,view.height - 5, view.visible_lines.len.str())
	// ctx.draw_text(view.width - 90,view.height - 4, buf.temp_path.str())
	// }
	// ctx.draw_text(view.width - 90,view.height - 2, buf.temp_string.str())


	// -- draw menu --
	tui_app.draw_menu(buf, view)

	// -- status bar --
	tui_app.draw_command_bar(buf, view)

	ctx.flush()
	buf.needs_render = false
}
