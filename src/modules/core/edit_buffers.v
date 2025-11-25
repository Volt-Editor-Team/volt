module core

import buffer { Buffer }
import util
import fs { get_working_dir_paths }
import os

pub fn (mut app App) add_new_buffer(b Buffer) {
	mut new_buf := Buffer.from_path(
		label: b.label
		name:  b.name
		path:  b.path
		type:  b.type
		// tabsize:    default_tabsize
		mode:       .normal
		p_mode:     b.p_mode
		menu_state: b.menu_state
	)
	app.viewport.fill_visible_lines(new_buf.buffer)
	app.viewport.update_offset(0, new_buf.buffer)
	if new_buf.path.starts_with(app.working_dir + os.path_separator) {
		new_buf.path = new_buf.path.replace(app.working_dir + os.path_separator, '')
	}

	// if app.buffers.len == 1 && app.buffers[app.active_buffer].path == 'Scratch' {
	if app.buffers.len == 1 && app.buffers[app.active_buffer].label == 'Scratch'
		&& app.buffers[app.active_buffer].name == 'Scratch' {
		app.buffers[0] = new_buf
	} else {
		app.buffers << new_buf
		app.change_active_buffer(app.buffers.len - 1)
	}
}

pub fn (mut app App) append_new_buffer(b Buffer) {
	mut new_buf := Buffer.from_path(
		label: b.label
		name:  b.name
		path:  b.path
		type:  b.type
		// tabsize:    default_tabsize
		mode:       .normal
		p_mode:     b.p_mode
		menu_state: b.menu_state
	)
	app.viewport.fill_visible_lines(new_buf.buffer)
	app.viewport.update_offset(0, new_buf.buffer)

	if new_buf.path.starts_with(app.working_dir + os.path_separator) {
		new_buf.path = new_buf.path.replace(app.working_dir + os.path_separator, '')
	}

	app.buffers << new_buf
}

pub fn (mut app App) add_prefilled_buffer(b Buffer, lines []string) {
	new_buf := Buffer.prefilled(Buffer{
		label: b.label
		name:  b.name
		path:  b.path
		type:  b.type
		// tabsize:    default_tabsize
		mode:       .normal
		p_mode:     b.p_mode
		menu_state: b.menu_state
	}, lines)

	app.viewport.fill_visible_lines(new_buf.buffer)
	app.viewport.update_offset(0, new_buf.buffer)

	if app.buffers.len == 1 && app.buffers[app.active_buffer].path == 'Scratch' {
		app.buffers[0] = new_buf
	} else {
		app.buffers << new_buf
		app.change_active_buffer(app.buffers.len - 1)
	}
}

pub fn (mut app App) change_active_buffer(idx int) {
	app.active_buffer = idx
}

pub fn (mut app App) add_directory_buffer() {
	parent_dir, lines := get_working_dir_paths()
	app.add_prefilled_buffer(Buffer{
		name:   'DIRECTORY'
		path:   parent_dir
		type:   .list
		p_mode: util.PersistantMode.directory
	}, lines)
}

pub fn (mut app App) add_stats_buffer() {
	lines := app.get_stats()
	app.add_prefilled_buffer(Buffer{
		name: 'DOCTOR'
		path: 'V DOCTOR OUTPUT'
		type: .gap
		mode: .normal
	}, lines)
}

pub fn (mut app App) add_help_buffer() {
	help_path := $embed_file('./src/modules/docs/help.txt').to_string().split_into_lines()
	app.add_prefilled_buffer(Buffer{
		name: 'HELP'
		path: 'HELP DOCUMENTATION'
		type: .list
		mode: .normal
	}, help_path)
}

pub fn (mut app App) close_buffer() {
	app.buffers.delete(app.active_buffer)

	if app.active_buffer > 0 {
		app.active_buffer--
	}
	if app.buffers.len == 0 {
		app.add_new_buffer(
			mode: util.Mode.normal
		)
	}
}
