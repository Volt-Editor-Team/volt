module gap

import math
import arrays

const gap_bytes = 64

pub fn (g GapBuffer) char_to_byte_index(i int) int {
	mut index := 0
	for ch_index, r in g.data.bytestr().runes_iterator() {
		if ch_index == i {
			return index
		}
		index += r.bytes().len
	}

	return index
}

pub fn (g GapBuffer) debug_string() string {
	before := g.data[..g.gap.start]
	after := g.data[g.gap.end..]
	gap_len := g.gap.end - g.gap.start
	capacity := g.data.cap - gap_len - (before.len + after.len)
	return '${before.bytestr()}[gap: ${gap_len}]${after.bytestr()}\ncapacity: ${capacity}'
}

// gap memcpy
fn (mut g GapBuffer) shift_gap_to(curs int) {
	gap_len := g.gap.end - g.gap.start
	byte_index := g.char_to_byte_index(curs)
	cursor := math.min(byte_index, g.data.len - gap_len)
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
		if g.data.cap < g.data.len + n_required {
			g.data.grow_cap(2 * math.max(g.data.len, gap_bytes))
		}
		g.data.grow_len(gap_bytes)
		g.gap.end = g.data.len
	}
}

fn (mut g GapBuffer) insert_rune(cursor int, ch rune) {
	check_gap_size(mut g, ch.length_in_bytes())
	byte_index := g.char_to_byte_index(cursor)
	g.shift_gap_to(byte_index)
	for i, byte in ch.bytes() {
		g.data[g.gap.start + i] = byte
	}
	g.gap.start += ch.length_in_bytes()
}

fn (mut g GapBuffer) insert_char(cursor int, ch u8) {
	check_gap_size(mut g, 1)
	byte_index := g.char_to_byte_index(cursor)
	g.shift_gap_to(byte_index)
	g.data[g.gap.start] = ch
	g.gap.start++
}

fn (mut g GapBuffer) insert_bytes(cursor int, bytes []u8) {
	check_gap_size(mut g, bytes.len)
	byte_index := g.char_to_byte_index(cursor)
	g.shift_gap_to(byte_index)
	for i, b in bytes {
		g.data[g.gap.start + i] = b
	}
	g.gap.start += bytes.len
}

fn (mut g GapBuffer) insert_slice(cursor int, slice []rune) {
	bytes := slice.string().bytes()
	g.insert_bytes(cursor, bytes)
}

fn (mut g GapBuffer) insert_string(cursor int, str string) {
	bytes := str.bytes()
	g.insert_bytes(cursor, bytes)
}
