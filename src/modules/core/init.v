module core

import buffer { Buffer, CommandBuffer }
import util { Mode }
import viewport { Viewport }
import ui { ColorScheme }
import os

pub struct App {
pub mut:
	buffers       []Buffer
	active_buffer int
	mode          Mode
	cmd_buffer    CommandBuffer
	viewport      Viewport
	theme         ColorScheme
	stats         shared []string
}

pub fn App.new(file_path string, width int, height int) &App {
	mut buffers := []Buffer{}
	buffers << Buffer.new(name: os.file_name(file_path), path: file_path, tabsize: default_tabsize)

	// viewport variables
	col_offset := 3 // start of all text
	view_height := height - 2 // subtract the command area
	line_num_to_text_gap := 3 // space between line number and code

	// total width available for code
	view_width := width - col_offset - line_num_to_text_gap
	margin := 5 // lines to edge visible (for scrolling)

	mut app := &App{
		buffers:       buffers
		active_buffer: 0
		mode:          Mode.normal
		viewport:      Viewport{
			col_offset:           col_offset
			height:               view_height
			width:                view_width
			line_num_to_text_gap: line_num_to_text_gap
			margin:               margin
		}
		theme:         ColorScheme{
			normal_cursor_color:        '#8282A0'
			insert_cursor_color:        '#7896C8'
			cursor_text_color:          '#141E32'
			active_line_bg_color:       '#323C5A'
			active_line_number_color:   '#B4B4C8'
			inactive_line_number_color: '#788296'
		}
	}
	app.viewport.update_width()

	go app.get_doctor_info()
	return app
}

pub fn (mut app App) get_doctor_info() {
	lock app.stats {
		v_doctor := os.execute('v doctor')
		stats := v_doctor.output.split_into_lines()
		app.stats = stats
	}
}

pub fn (mut app App) get_stats() shared []string {
	return app.stats
}
