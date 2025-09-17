module colors

import encoding.hex
import term.ui { Color }

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
