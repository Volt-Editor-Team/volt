module main

import controller
import ui

fn main() {
	width, height := ui.get_terminal_size()
	file_path := './src/main.v'
	tabsize := 4

	mut app := controller.App.new(file_path, tabsize, width, height)

	app.tui = controller.initialize_tui(mut app, ui.frame)

	app.tui.run()!
}
