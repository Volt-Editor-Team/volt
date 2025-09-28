module colors

import encoding.hex
import term.ui { Color }
import fs

pub fn hex_to_tui_color(hexcode string) !Color {
	clean := if hexcode.starts_with('#') { hexcode[1..] } else { hexcode }
	bytes := hex.decode(clean)!
	if bytes.len != 3 {
		return error('Hexcode ${hexcode} is invalid')
	}
	return Color{
		r: bytes[0]
		g: bytes[1]
		b: bytes[2]
	}
}

pub fn get_cd_text_color(path string) Color {
	if fs.is_dir(path) {
		return royal_blue
	}
	return white
}

pub const default_insert_cursor_color = Color{
	r: 120
	g: 150
	b: 200
}
pub const default_normal_cursor_color = Color{
	r: 130
	g: 130
	b: 160
}
pub const default_cursor_text_color = Color{
	r: 20
	g: 30
	b: 50
}
pub const default_active_line_bg_color = Color{
	r: 50
	g: 60
	b: 90
}
pub const default_active_line_number_color = Color{
	r: 180
	g: 180
	b: 200
}
pub const default_inactive_line_number_color = Color{
	r: 120
	g: 130
	b: 150
}
pub const neutral_grey = Color{
	r: 38
	g: 50
	b: 56
}

pub const teal = Color{
	r: 0
	g: 150
	b: 136
}

pub const amber = Color{
	r: 255
	g: 171
	b: 64
}

pub const amber_2 = Color{
	r: 204
	g: 136
	b: 51
}

pub const purple = Color{
	r: 156
	g: 36
	b: 176
}

pub const deep_indigo = Color{
	r: 63
	g: 81
	b: 181
}

pub const deep_indigo_2 = Color{
	r: 50
	g: 64
	b: 144
}

pub const white = Color{
	r: 255
	g: 255
	b: 255
}

pub const dark_blue = Color{
	r: 0
	g: 0
	b: 139
}
pub const dark_grey_blue = Color{
	r: 40
	g: 44
	b: 52
}

pub const muted_dark_blue = Color{
	r: 25
	g: 25
	b: 112
}

pub const royal_blue = Color{
	r: 65
	g: 105
	b: 225
}

pub const dark_red = Color{
	r: 139
	g: 0
	b: 0
}

pub const black = Color{
	r: 0
	g: 0
	b: 0
}

pub const google_dark_grey = Color{
	r: 32
	g: 33
	b: 36
}

pub const vscode_classic = Color{
	r: 30
	g: 30
	b: 30
}

pub const lavender_violet = Color{
	r: 187
	g: 154
	b: 247
}
