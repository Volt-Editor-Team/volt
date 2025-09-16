module main

import core
import ui.tui
// import os
// import time

fn main() {
	// ! this runs 'v doctor' in the background !
	// ch := chan string{cap: 1}
	// go fn (ch chan string) {
	// 	v_doctor := os.execute('v doctor')
	// 	ch <- v_doctor.output
	// }(ch)
	// doctor_output := <-ch
	// println(doctor_output)

	width, height := tui.get_terminal_size()
	// file_path := './testdata/simple.txt'
	file_path := './src/modules/ui/tui/ui_loop.v'

	mut core_app := core.App.new(file_path, width, height)

	mut tui_app := tui.TuiApp.new(&core_app)

	tui_app.tui.run()!
}
