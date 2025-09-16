module core

import cursor { LogicalCursor, VisualCursor }
import buffer { Buffer, CommandBuffer }
import util { Mode }
import viewport { Viewport }
import ui { ColorScheme }

pub struct App {
pub mut:
	buffer         Buffer
	logical_cursor LogicalCursor
	visual_cursor  VisualCursor
	saved_cursor   LogicalCursor
	mode           Mode
	cmd_buffer     CommandBuffer
	viewport       Viewport
	theme          ColorScheme
}

pub fn App.new(file_path string, tabsize int, width int, height int) App {
	mut app := App{
		buffer:   buffer.Buffer.new(file_path, tabsize)
		mode:     Mode.normal
		viewport: Viewport{
			col_offset: 3
			height:     height - 2
			width:      width - 1
			margin:     5
		}
		theme:    ColorScheme{
			cursor_color:               '#7896C8'
			cursor_text_color:          '#141E32'
			active_line_bg_color:       '#323C5A'
			active_line_number_color:   '#B4B4C8'
			inactive_line_number_color: '#788296'
		}
	}
	app.viewport.update_width()

	return app
}
