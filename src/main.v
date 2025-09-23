module main

// program state and rendering proceedure
import core
import ui.tui
// necessary for parsing cli arguments
import docs { create_cli }
import os
import cli as c

fn main() {
	mut cli := create_cli()

	cli.execute = fn (cmd c.Command) ! {
		width, height := tui.get_terminal_size()
		// file_path := './testdata/simple.txt'
		file_path := './src/modules/ui/tui/ui_loop.v'
		mut core_app := core.App.new(file_path, width, height)
		mut tui_app := tui.TuiApp.new(core_app)

		tui_app.tui.run()!
	}

	cli.setup()
	args := os.args.map(if it.starts_with('--') { it.replace_once('-', '') } else { it })
	cli.parse(args)
}
