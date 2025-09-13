module core

import cursor
import buffer
import util
import viewport

pub struct App {
pub mut:
	buffer         buffer.Buffer
	logical_cursor cursor.LogicalCursor
	visual_cursor  cursor.VisualCursor
	saved_cursor   cursor.LogicalCursor
	mode           util.Mode
	cmd_buffer     buffer.CommandBuffer
	viewport       viewport.Viewport
}

pub fn App.new(file_path string, tabsize int, width int, height int) App {
	mut app := App{
		buffer:   buffer.Buffer.new(file_path, tabsize)
		mode:     util.Mode.normal
		viewport: viewport.Viewport{
			col_offset: 3
			height:     height - 2
			width:      width - 1
			margin:     5
		}
	}
	app.viewport.update_width()

	return app
}
