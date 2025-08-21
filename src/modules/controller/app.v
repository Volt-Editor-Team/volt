module controller

import cursor
import buffer
import util
import viewport
import term.ui as tui

pub struct App {
pub mut:
	tui          &tui.Context = unsafe { nil }
	buffer       buffer.Buffer
	cursor       cursor.Cursor
	saved_cursor cursor.Cursor
	mode         util.Mode
	cmd_buffer   string
	viewport     viewport.Viewport
}

pub fn App.new(file_path string, tabsize int, width int, height int) &App {
	return &App{
		buffer:   buffer.Buffer.new(file_path, tabsize)
		cursor:   cursor.Cursor{
			x:           0
			y:           0
			visual_x:    0
			desired_col: 0
		}
		mode:     util.Mode.normal
		viewport: viewport.Viewport{
			row_offset: 0
			col_offset: 0
			height:     height - 2
			width:      width
			margin:     5
		}
	}
}

pub fn get_app(x voidptr) &App {
	return unsafe { &App(x) }
}

pub fn initialize_tui(mut app &App, ui_fn fn (x voidptr)) &tui.Context {
	return tui.init(
		user_data:   app
		event_fn:    event
		frame_fn:    ui_fn
		hide_cursor: false
	)
}
