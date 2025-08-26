module controller

import cursor
import buffer
import util
import viewport
import term.ui as tui

pub struct App {
pub mut:
	tui            &tui.Context = unsafe { nil }
	buffer         buffer.Buffer
	logical_cursor cursor.LogicalCursor
	visual_cursor  cursor.VisualCursor
	saved_cursor   cursor.LogicalCursor
	mode           util.Mode
	cmd_buffer     buffer.CommandBuffer
	viewport       viewport.Viewport
}

pub fn App.new(file_path string, tabsize int, width int, height int) &App {
	return &App{
		buffer:   buffer.Buffer.new(file_path, tabsize)
		mode:     util.Mode.normal
		viewport: viewport.Viewport{
			height: height - 2
			width:  width
			margin: 5
		}
	}
}

pub fn get_app(x voidptr) &App {
	return unsafe { &App(x) }
}

pub fn initialize_tui(mut app App, ui_fn fn (x voidptr)) &tui.Context {
	return tui.init(
		user_data:   app
		event_fn:    event
		frame_fn:    ui_fn
		hide_cursor: true
	)
}
