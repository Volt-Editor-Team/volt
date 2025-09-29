module gap

import math
import arrays

pub struct GapBuffer {
pub mut:
	data []rune
mut:
	gap Gap
}

pub struct Gap {
mut:
	start int
	end   int
}

pub fn GapBuffer.new(g GapBuffer) GapBuffer {
	return GapBuffer{
		data: []rune{len: g.data.len, cap: g.data.len * 2, init: g.data[index]}
		gap:  Gap{
			start: g.data.len
			end:   g.data.len * 2
		}
	}
}

// gap memcpy
pub fn (mut g GapBuffer) shift_gap_to(curs int) {
	gap_len := g.gap.end - g.gap.start
	cursor := math.min(curs, g.data.len - gap_len)
	if cursor == g.gap.start {
		return
	}
	if g.gap.start < cursor {
		// gap is before the cursor
		delta := cursor - g.gap.start
		for i in 0 .. delta {
			g.data[g.gap.start + i] = g.data[g.gap.end + i]
		}
		g.gap.start += delta
		g.gap.end += delta
	} else if g.gap.start > cursor {
		// gap is after the cursor
		delta := g.gap.start - cursor
		for i := delta - 1; i >= 0; i-- {
			g.data[g.gap.end - delta + i] = g.data[cursor + i]
		}
		g.gap.start -= delta
		g.gap.end -= delta
	}
}

// reallocation on gap too small
pub fn check_gap_size(mut g GapBuffer, n_required int) {
	gap_len := g.gap.end - g.gap.start
	if gap_len < n_required {
		mut new_data := []rune{len: g.data.len + n_required, cap: 2 * math.max(g.data.len,
			n_required)}
		arrays.copy(mut new_data, g.data)
		// gap.end = gap.start + ((2 *math.max(g.data.len, n_required)) - g.data.len)
		g.data = new_data
		g.gap.end = g.data.len
	}
}

type InsertValue = rune | u8 | []rune | string

pub fn (mut g GapBuffer) insert(cursor int, val InsertValue) {
	match val {
		rune {
			g.insert_rune(cursor, val)
		}
		u8 {
			g.insert_char(cursor, val)
		}
		[]rune {
			g.insert_slice(cursor, val)
		}
		string {
			g.insert_string(cursor, val)
		}
	}
}

pub fn (mut g GapBuffer) insert_rune(cursor int, ch rune) {
	check_gap_size(mut g, 1)
	g.shift_gap_to(cursor)
	g.data[g.gap.start] = ch
	g.gap.start++
}

pub fn (mut g GapBuffer) insert_char(cursor int, ch u8) {
	check_gap_size(mut g, 1)
	g.shift_gap_to(cursor)
	g.data[g.gap.start] = rune(ch)
	g.gap.start++
}

pub fn (mut g GapBuffer) insert_slice(cursor int, slice []rune) {
	check_gap_size(mut g, slice.len)
	g.shift_gap_to(cursor)
	for i, r in slice {
		g.data[g.gap.start + i] = r
	}
	g.gap.start += slice.len
}

pub fn (mut g GapBuffer) insert_string(cursor int, str string) {
	runes := str.runes()
	g.insert_slice(cursor, runes)
}

pub fn (mut g GapBuffer) remove(cursor int, count int) {
	g.shift_gap_to(cursor)
	g.gap.end = math.min(g.gap.end + count, g.data.len)
}
