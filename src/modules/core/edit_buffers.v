module core

import buffer { Buffer }
import util
import fs { get_working_dir_paths }

pub fn (mut app App) add_new_buffer(b Buffer) {
	app.buffers << Buffer.new(
		name:    b.name
		path:    b.path
		lines:   b.lines
		tabsize: default_tabsize
		mode:    .normal
		p_mode:  b.p_mode
	)
	app.change_active_buffer(app.buffers.len - 1)
}

pub fn (mut app App) change_active_buffer(idx int) {
	app.active_buffer = idx
}

pub fn (mut app App) add_directory_buffer() {
	parent_dir, lines := get_working_dir_paths()
	app.add_new_buffer(
		name:   'DIRECTORY'
		path:   parent_dir
		lines:  lines
		p_mode: util.PersistantMode.directory
	)
}

pub fn (mut app App) add_stats_buffer() {
	lines := app.get_stats()
	app.add_new_buffer(
		name:  'DOCTOR'
		path:  'V DOCTOR OUTPUT'
		lines: lines
		mode:  .normal
	)
}

pub fn (mut app App) close_buffer() {
	app.buffers.delete(app.active_buffer)

	if app.active_buffer > 0 {
		app.active_buffer--
	}
	if app.buffers.len == 0 {
		app.add_new_buffer(mode: util.Mode.normal)
	}
}

// pub fn (mut app App) swap_to_temp_fuzzy_buffer(mut buf Buffer) {
// 	mut path := buf.path
// 	if !fs.is_dir(path) {
// 		path = os.dir(path)
// 	}

// 	go app.async_fill(mut buf)
// }

// pub fn (mut app App) async_fill(mut buf Buffer) {
// 	for i in 0 .. 12 {
// 		lock {
// 			buf.temp_data << 'fuzzy ${i}'
// 		}
// 		time.sleep(50 * time.millisecond)
// 	}
// }
