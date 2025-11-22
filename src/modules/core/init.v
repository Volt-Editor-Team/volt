module core

import buffer { Buffer, CommandBuffer }
// import buffer.list { ListBuffer }
import viewport { Viewport }
import ui { ColorScheme }
import os

pub struct App {
pub:
	os string = @OS
pub mut:
	working_dir   string
	buffers       []Buffer
	swap_map      map[int]Buffer
	active_buffer int
	// prev_mode     Mode
	cmd_buffer CommandBuffer
	viewport   Viewport
	theme      ColorScheme
	stats      []string
	// tracking for single buffer
	has_directory_buffer bool
	has_stats_opened     bool
}

pub fn App.new(width int, height int) &App {
	mut app := &App{}

	app.working_dir = os.abs_path('.')

	app.theme = ColorScheme{
		normal_text_color:          '#ffffff'
		normal_cursor_color:        '#8282A0'
		insert_cursor_color:        '#7896C8'
		cursor_text_color:          '#1E1E1E'
		active_line_bg_color:       '#323C5A'
		active_line_number_color:   '#B4B4C8'
		inactive_line_number_color: '#788296'
		background_color:           '#1E1E1E'
		command_bar_color:          '#324090'
		tab_bar_color:              '#324090'
		active_tab_color:           '#CC8933'
	}

	// viewport variables
	col_offset := 1 // start of all text
	view_height := height - 1 // subtract the command area
	line_num_to_text_gap := 3 // space between line number and code
	// total width available for code
	view_width := width - col_offset - line_num_to_text_gap
	margin := 8 // lines to edge visible (for scrolling)
	app.viewport = Viewport{
		col_offset:           col_offset
		height:               view_height
		width:                view_width
		line_num_to_text_gap: line_num_to_text_gap
		margin:               margin
	}

	mut buffers := []Buffer{}
	buffers << Buffer.from_path(Buffer{
		type:       .list
		menu_state: true
		tabsize:    default_tabsize
	})
	app.buffers = buffers
	app.active_buffer = 0

	app.viewport.update_width()

	// go app.get_doctor_info()
	return app
}

pub fn (mut app App) get_doctor_info() {
	lock {
		v_doctor := os.execute('v doctor')
		stats := v_doctor.output.split_into_lines()
		app.stats = stats
	}
	return
}

pub fn (mut app App) get_stats() []string {
	return app.stats
}
