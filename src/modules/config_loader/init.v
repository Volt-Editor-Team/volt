module config_loader

import os
import toml

// ---------- Types & defaults ----------

pub enum LineNumbers { off on relative }
pub enum CursorStyle { block bar underline }

@[noinit]
pub struct Theme {
pub mut:
	fg           string = 'white'
	bg           string = 'black'
	accent       string = 'cyan'
	gutter       string = 'bright_black'
	cursor       string = 'bright_cyan'
	statusbar_bg string = 'bright_black'
	statusbar_fg string = 'white'
}

@[noinit]
pub struct Editor {
pub mut:
	tab_width    int         = 4
	soft_wrap    bool        = true
	line_numbers LineNumbers = .relative
	cursor_style CursorStyle = .block
}

@[noinit]
pub struct Keys {
pub mut:
	save         string = 'ctrl+s'
	quit         string = 'ctrl+q'
	open         string = 'ctrl+o'
	toggle_wrap  string = 'alt+w'
}

@[noinit]
pub struct Config {
pub mut:
	editor Editor
	theme  Theme
	keys   Keys
}

// ---------- helpers ----------

fn parse_line_numbers(s string) LineNumbers {
	return match s.to_lower() {
		'on' { .on }
		'relative' { .relative }
		else { .off }
	}
}

fn parse_cursor_style(s string) CursorStyle {
	return match s.to_lower() {
		'bar' { .bar }
		'underline' { .underline }
		else { .block }
	}
}

// Reads ./config.toml if it exists, returns a Result (!string)
fn read_local_config_text() !string {
	if os.is_file('config.toml') {
		return os.read_file('config.toml')
	}
	return error('no local config.toml')
}

// ---------- public API ----------

// Safely loads ./config.toml. On any error, returns defaults.
pub fn load_config() Config {
	mut cfg := Config{} // defaults

	content := read_local_config_text() or { return cfg }
	doc := toml.parse_text(content) or { return cfg }

	// ------- [editor] -------
	if v := doc.value_opt('editor.tab_width')    { cfg.editor.tab_width = v.int() }
	if v := doc.value_opt('editor.soft_wrap')    { cfg.editor.soft_wrap = v.bool() }
	if v := doc.value_opt('editor.line_numbers') { cfg.editor.line_numbers = parse_line_numbers(v.string()) }
	if v := doc.value_opt('editor.cursor_style') { cfg.editor.cursor_style = parse_cursor_style(v.string()) }

	// ------- [theme] -------
	if v := doc.value_opt('theme.fg')           { cfg.theme.fg = v.string() }
	if v := doc.value_opt('theme.bg')           { cfg.theme.bg = v.string() }
	if v := doc.value_opt('theme.accent')       { cfg.theme.accent = v.string() }
	if v := doc.value_opt('theme.gutter')       { cfg.theme.gutter = v.string() }
	if v := doc.value_opt('theme.cursor')       { cfg.theme.cursor = v.string() }
	if v := doc.value_opt('theme.statusbar_bg') { cfg.theme.statusbar_bg = v.string() }
	if v := doc.value_opt('theme.statusbar_fg') { cfg.theme.statusbar_fg = v.string() }

	// ------- [keys] -------
	if v := doc.value_opt('keys.save')        { cfg.keys.save = v.string() }
	if v := doc.value_opt('keys.quit')        { cfg.keys.quit = v.string() }
	if v := doc.value_opt('keys.open')        { cfg.keys.open = v.string() }
	if v := doc.value_opt('keys.toggle_wrap') { cfg.keys.toggle_wrap = v.string() }

	return cfg
}

