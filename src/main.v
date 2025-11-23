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
	args := os.args.map(if it.starts_with('--') { it.replace_once('-', '') } else { it })

	cli.execute = fn (cmd c.Command) ! {
		width, height := tui.get_terminal_size()
		// file_path := './testdata/simple.txt'
		// file_path := './src/modules/ui/tui/ui_loop.v'
		mut core_app := core.App.new(width, height)
		mut tui_app := tui.TuiApp.new(core_app)

		if os.args.len > 1 {
			mut open_fuzzy := false
			for i, arg in os.args[1..] {
				if arg == '.' {
					if i == 0 {
						if os.args.len > 2 {
							open_fuzzy = true
						} else {
							core_app.add_new_buffer(
								mode:       .normal
								type:       .list
								p_mode:     .default
								menu_state: true
							)
							mut buffer := &core_app.buffers[core_app.active_buffer]
							buffer.temp_path = core_app.working_dir
							buffer.temp_list.clear()
							buffer.temp_cursor.y = 0
							buffer.temp_cursor.x = 0
							buffer.mode = .insert
							buffer.temp_fuzzy_type = .file
							buffer.menu_state = false
							buffer.open_fuzzy_find(buffer.path, .file)
						}
					} else {
						panic('use "." only as the first argument')
					}
				} else {
					core_app.add_new_buffer(
						name:       arg
						path:       arg
						type:       .list
						mode:       .normal
						p_mode:     .default
						menu_state: true
					)
					if open_fuzzy {
						mut buffer := &core_app.buffers[core_app.active_buffer]
						buffer.temp_path = core_app.working_dir
						buffer.temp_list.clear()
						buffer.temp_cursor.y = 0
						buffer.temp_cursor.x = 0
						buffer.mode = .insert
						buffer.temp_fuzzy_type = .file
						buffer.menu_state = false
						buffer.open_fuzzy_find(buffer.path, .file)
						open_fuzzy = false
					}
				}
			}
		}
		tui_app.tui.run()!
	}

	cli.setup()
	cli.parse(args)
}
