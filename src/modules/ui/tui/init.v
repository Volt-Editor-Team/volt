module tui

import util.colors
import ui
import core.controller as ctl
import term.ui as t

struct TuiTheme {
mut:
	cursor_color               t.Color
	cursor_text_color          t.Color
	active_line_bg_color       t.Color
	active_line_number_color   t.Color
	inactive_line_number_color t.Color
}

fn TuiTheme.new(theme ui.ColorScheme) TuiTheme {
	return TuiTheme{
		cursor_color:               colors.hex_to_tui_color(theme.cursor_color) or {
			colors.default_cursor_color
		}
		cursor_text_color:          colors.hex_to_tui_color(theme.cursor_text_color) or {
			colors.default_cursor_text_color
		}
		active_line_bg_color:       colors.hex_to_tui_color(theme.active_line_bg_color) or {
			colors.default_active_line_bg_color
		}
		active_line_number_color:   colors.hex_to_tui_color(theme.active_line_number_color) or {
			colors.default_active_line_number_color
		}
		inactive_line_number_color: colors.hex_to_tui_color(theme.inactive_line_number_color) or {
			colors.default_inactive_line_number_color
		}
	}
}

pub fn get_tui(x voidptr) &TuiApp {
	return unsafe { &TuiApp(x) }
}

pub struct TuiApp {
pub mut:
	core  voidptr
	tui   &t.Context = unsafe { nil }
	theme TuiTheme
}

pub fn TuiApp.new(core voidptr) &TuiApp {
	mut tui_app := &TuiApp{}
	tui_app.initialize_tui(core)

	return tui_app
}

pub fn (mut tui_app TuiApp) initialize_tui(core voidptr) {
	tui_app.core = core
	app := ctl.get_app(core)
	tui_app.theme = TuiTheme.new(app.theme)
	tui_app.tui = t.init(
		user_data:   tui_app
		event_fn:    event_wrapper
		frame_fn:    ui_loop
		hide_cursor: true
	)
}

pub fn event_wrapper(e &t.Event, x voidptr) {
	tui_app := get_tui(x)
	event_type := convert_event_type(e.typ)
	key_code := convert_key_code(e.code)

	input := ctl.UserInput{
		e:    event_type
		code: key_code
	}

	ctl.event_loop(input, tui_app.core)
}

fn convert_event_type(e t.EventType) ctl.EventType {
	return match e {
		.unknown { .unknown }
		.mouse_down { .mouse_down }
		.mouse_up { .mouse_up }
		.mouse_move { .mouse_move }
		.mouse_drag { .mouse_drag }
		.mouse_scroll { .mouse_scroll }
		.key_down { .key_down }
		.resized { .resized }
	}
}

fn convert_key_code(k t.KeyCode) ctl.KeyCode {
	return match k {
		.null { .null }
		.tab { .tab }
		.enter { .enter }
		.escape { .escape }
		.space { .space }
		.backspace { .backspace }
		.exclamation { .exclamation }
		.double_quote { .double_quote }
		.hashtag { .hashtag }
		.dollar { .dollar }
		.percent { .percent }
		.ampersand { .ampersand }
		.single_quote { .single_quote }
		.left_paren { .left_paren }
		.right_paren { .right_paren }
		.asterisk { .asterisk }
		.plus { .plus }
		.comma { .comma }
		.minus { .minus }
		.period { .period }
		.slash { .slash }
		._0 { ._0 }
		._1 { ._1 }
		._2 { ._2 }
		._3 { ._3 }
		._4 { ._4 }
		._5 { ._5 }
		._6 { ._6 }
		._7 { ._7 }
		._8 { ._8 }
		._9 { ._9 }
		.colon { .colon }
		.semicolon { .semicolon }
		.less_than { .less_than }
		.equal { .equal }
		.greater_than { .greater_than }
		.question_mark { .question_mark }
		.at { .at }
		.a { .a }
		.b { .b }
		.c { .c }
		.d { .d }
		.e { .e }
		.f { .f }
		.g { .g }
		.h { .h }
		.i { .i }
		.j { .j }
		.k { .k }
		.l { .l }
		.m { .m }
		.n { .n }
		.o { .o }
		.p { .p }
		.q { .q }
		.r { .r }
		.s { .s }
		.t { .t }
		.u { .u }
		.v { .v }
		.w { .w }
		.x { .x }
		.y { .y }
		.z { .z }
		.left_square_bracket { .left_square_bracket }
		.backslash { .backslash }
		.right_square_bracket { .right_square_bracket }
		.caret { .caret }
		.underscore { .underscore }
		.backtick { .backtick }
		.left_curly_bracket { .left_curly_bracket }
		.vertical_bar { .vertical_bar }
		.right_curly_bracket { .right_curly_bracket }
		.tilde { .tilde }
		.insert { .insert }
		.delete { .delete }
		.up { .up }
		.down { .down }
		.right { .right }
		.left { .left }
		.page_up { .page_up }
		.page_down { .page_down }
		.home { .home }
		.end { .end }
		.f1 { .f1 }
		.f2 { .f2 }
		.f3 { .f3 }
		.f4 { .f4 }
		.f5 { .f5 }
		.f6 { .f6 }
		.f7 { .f7 }
		.f8 { .f8 }
		.f9 { .f9 }
		.f10 { .f10 }
		.f11 { .f11 }
		.f12 { .f12 }
		.f13 { .f13 }
		.f14 { .f14 }
		.f15 { .f15 }
		.f16 { .f16 }
		.f17 { .f17 }
		.f18 { .f18 }
		.f19 { .f19 }
		.f20 { .f20 }
		.f21 { .f21 }
		.f22 { .f22 }
		.f23 { .f23 }
		.f24 { .f24 }
	}
}
