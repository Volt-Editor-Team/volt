module main

import core
import ui.tui

fn main() {
	width, height := tui.get_terminal_size()
	file_path := './testdata/simple.txt'
	tabsize := 4

	mut core_app := core.App.new(file_path, tabsize, width, height)

	core_app.tui = tui.initialize_tui(mut core_app)

	core_app.tui.run()!
}
