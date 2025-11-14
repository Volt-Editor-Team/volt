module tui

import core.controller as ctl
import term.ui as t

pub fn convert_modifier(e t.Modifiers) ctl.Modifier {
	return match e {
		.ctrl { .ctrl }
		.shift { .shift }
		.alt { .alt }
		else { .none }
	}
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
