module core

import buffer { Buffer, CommandBuffer }
import util { Mode }
import viewport { Viewport }
import ui { ColorScheme }

pub struct App {
pub mut:
	buffers       []Buffer
	active_buffer int
	mode          Mode
	cmd_buffer    CommandBuffer
	viewport      Viewport
	theme         ColorScheme
}

pub fn App.new(file_path string, tabsize int, width int, height int) App {
	mut buffers := []Buffer{}
	buffers << Buffer.new(file_path, tabsize)
	mut app := App{
		buffers:       buffers
		active_buffer: 0
		mode:          Mode.normal
		viewport:      Viewport{
			col_offset: 3
			height:     height - 2
			width:      width - 1
			margin:     5
		}
		theme:         ColorScheme{
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
