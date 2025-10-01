module gap

import math
import arrays

pub fn (g GapBuffer) debug_string() string {
	before := g.data[..g.gap.start].string()
	after := g.data[g.gap.end..].string()
	gap_size := g.data.cap - (before.len + after.len)
	return before + '[gap:' + gap_size.str() + ']' + after
}

// gap memcpy
fn (mut g GapBuffer) shift_gap_to(curs int) {
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
fn check_gap_size(mut g GapBuffer, n_required int) {
	gap_len := g.gap.end - g.gap.start
	if gap_len < n_required {
		g.shift_gap_to(g.data.len - gap_len)
		mut new_data := []rune{len: g.data.len + n_required - gap_len, cap: 2 * math.max(g.data.len,
			n_required)}
		arrays.copy(mut new_data, g.data)
		g.data = new_data
		g.gap.end = g.data.len
	}
}

fn (mut g GapBuffer) insert_rune(cursor int, ch rune) {
	check_gap_size(mut g, 1)
	g.shift_gap_to(cursor)
	g.data[g.gap.start] = ch
	g.gap.start++
}

fn (mut g GapBuffer) insert_char(cursor int, ch u8) {
	check_gap_size(mut g, 1)
	g.shift_gap_to(cursor)
	g.data[g.gap.start] = rune(ch)
	g.gap.start++
}

fn (mut g GapBuffer) insert_slice(cursor int, slice []rune) {
	check_gap_size(mut g, slice.len)
	g.shift_gap_to(cursor)
	for i, r in slice {
		g.data[g.gap.start + i] = r
	}
	g.gap.start += slice.len
}

fn (mut g GapBuffer) insert_string(cursor int, str string) {
	runes := str.runes()
	g.insert_slice(cursor, runes)
}
