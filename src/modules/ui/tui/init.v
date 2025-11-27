module tui

import core.controller as ctl
import term.ui as t

pub fn get_tui(x voidptr) &TuiApp {
	return unsafe { &TuiApp(x) }
}

pub struct TuiApp {
pub mut:
	core  voidptr
	tui   &TuiContext = unsafe { nil }
	theme TuiTheme
}

type TuiContext = t.Context

pub fn TuiApp.new(core voidptr) &TuiApp {
	mut tui_app := &TuiApp{}
	tui_app.initialize_tui(core)

	return tui_app
}

pub fn (mut tui_app TuiApp) initialize_tui(core voidptr) {
	tui_app.core = core
	app := ctl.get_app(core)
	tui_app.theme = TuiTheme.new(app.theme)
	tui_app.tui = t.init(
		init_fn:        full_redraw
		user_data:      tui_app
		event_fn:       event_wrapper
		frame_fn:       full_redraw
		capture_events: true
		hide_cursor:    true
		frame_rate:     60
	)
}

pub fn event_wrapper(e &t.Event, x voidptr) {
	if e.typ == .key_down {
		mut tui_app := get_tui(x)
		mut app := ctl.get_app(tui_app.core)
		mut view := &app.viewport
		mut buf := &app.buffers[app.active_buffer]

		// handle menu toggle regardless
		if e.modifiers == if app.os == 'windows' {
			t.Modifiers.ctrl
		} else {
			t.Modifiers.alt
		} {
			if e.code == .m {
				buf.menu_state = !buf.menu_state
				buf.needs_render = true
				return
			}
		}
		if e.modifiers == t.Modifiers.alt {
			if e.code == .comma {
				view.existing_cursors[app.active_buffer] = view.cursor
				view.existing_offsets[app.active_buffer] = view.row_offset
				if app.buffers.len > 1 {
					if app.active_buffer == 0 {
						app.active_buffer = app.buffers.len - 1
					} else {
						app.active_buffer -= 1
					}
				}

				view.row_offset = if view.existing_offsets.keys().contains(app.active_buffer) {
					view.existing_offsets[app.active_buffer]
				} else {
					0
				}
				if view.existing_cursors.keys().contains(app.active_buffer) {
					view.cursor = view.existing_cursors[app.active_buffer]
				} else {
					view.cursor.x = 0
					view.cursor.y = 0
					view.cursor.flat_index = 0
					view.cursor.visual_x = 0
					view.cursor.desired_col = 0
				}

				view.update_offset(view.cursor.y, buf.buffer)
				view.fill_visible_lines(app.buffers[app.active_buffer].buffer)
				buf.needs_render = true
				return
			}
			if e.code == .period {
				view.existing_cursors[app.active_buffer] = view.cursor
				view.existing_offsets[app.active_buffer] = view.row_offset
				if app.buffers.len > 1 {
					if app.active_buffer == app.buffers.len - 1 {
						app.active_buffer = 0
					} else {
						app.active_buffer += 1
					}
				}
				view.row_offset = if view.existing_offsets.keys().contains(app.active_buffer) {
					view.existing_offsets[app.active_buffer]
				} else {
					0
				}
				if view.existing_cursors.keys().contains(app.active_buffer) {
					view.cursor = view.existing_cursors[app.active_buffer]
				} else {
					view.cursor.x = 0
					view.cursor.y = 0
					view.cursor.flat_index = 0
					view.cursor.visual_x = 0
					view.cursor.desired_col = 0
				}
				view.update_offset(view.cursor.y, buf.buffer)
				view.fill_visible_lines(app.buffers[app.active_buffer].buffer)
				buf.needs_render = true
				return
			}
		}

		// if not menu toggle, send to event loop
		event_type := convert_event_type(e.typ)
		key_code := convert_key_code(e.code)
		modifier := convert_modifier(e.modifiers)
		input := ctl.UserInput{
			mod:  modifier
			e:    event_type
			code: key_code
		}

		ctl.event_loop(input, tui_app.core)
		buf.needs_render = true
	}
}
