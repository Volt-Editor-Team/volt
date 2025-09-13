module main

import core
import ui.tui

fn main() {
	width, height := tui.get_terminal_size()
	file_path := './testdata/simple.txt'
	tabsize := 4

	mut core_app := core.App.new(file_path, tabsize, width, height)

	mut tui_app := tui.TuiApp.new(&core_app)

	tui_app.tui.run()!
}
