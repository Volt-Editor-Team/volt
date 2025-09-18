module main

import core
import ui.tui
import os
// import time

fn run_doctor() chan []string {
	ch := chan []string{cap: 1}

	go fn (ch chan []string) {
		v_doctor := os.execute('v doctor')
		stats := v_doctor.output.split_into_lines()
		ch <- stats
	}(ch)

	return ch
}

fn main() {
	width, height := tui.get_terminal_size()
	// file_path := './testdata/simple.txt'
	file_path := './src/modules/ui/tui/ui_loop.v'
	mut core_app := core.App.new(file_path, width, height)

	// ! this runs 'v doctor' in the background !
	// go fn [mut core_app] () {
	// 	v_doctor := os.execute('v doctor')
	// 	stats := v_doctor.output.split_into_lines()
	// 	core_app.set_stats(stats)
	// }()

	mut tui_app := tui.TuiApp.new(core_app)

	tui_app.tui.run()!
}
