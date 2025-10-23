module gap

fn (mut g GapBuffer) insert_rune(cursor int, ch rune) ! {
	g.check_gap_size(1)
	g.shift_gap_to(cursor)
	g.data[g.gap.start] = ch
	g.gap.start++
}

fn (mut g GapBuffer) insert_char(cursor int, ch u8) ! {
	g.check_gap_size(1)
	g.shift_gap_to(cursor)
	g.data[g.gap.start] = rune(ch)
	g.gap.start++
}

fn (mut g GapBuffer) insert_runes(cursor int, slice []rune) ! {
	g.check_gap_size(slice.len)
	g.shift_gap_to(cursor)
	for i, ch in slice {
		g.data[g.gap.start + i] = ch
	}
	g.gap.start += slice.len
}

fn (mut g GapBuffer) insert_bytes(cursor int, bytes []u8) ! {
	runes := bytes.bytestr().runes()
	g.insert_runes(cursor, runes)!
}

fn (mut g GapBuffer) insert_string(cursor int, str string) ! {
	runes := str.runes()
	g.insert_runes(cursor, runes)!
}
