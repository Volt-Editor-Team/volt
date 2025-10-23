module gap

import math
import buffer { InsertValue, RopeData }

// --- initialization ---
struct GapBuffer {
mut:
	data []rune
	gap  Gap
}

struct Gap {
mut:
	start int
	end   int
}

pub fn GapBuffer.new() GapBuffer {
	return GapBuffer{}
}

pub fn GapBuffer.from(data []rune) GapBuffer {
	return GapBuffer{
		data: []rune{len: data.len, cap: math.min(max_cap, 2 * data.len), init: data[index]}
		gap:  Gap{
			start: data.len
			end:   data.len
		}
	}
}

// --- buffer interface ---
// - [x] insert(cursor int, s InsertValue)
// - [x] delete(cursor int, n int)
// - [x] to_string() string
// - [x] len() int
// - [x] line_count() int
// - [ ] line_at(i int)
// - [x] char_at(i int) rune
// - [ ] slice(start int, end int) string
// - [ ] index_to_line_col(i int) (int, int)
// - [ ] line_col_to_index(line int, col int) int

pub fn (mut g GapBuffer) insert(index int, val InsertValue) ! {
	match val {
		rune {
			g.insert_rune(index, val)!
		}
		u8 {
			g.insert_char(index, val)!
		}
		[]rune {
			g.insert_runes(index, val)!
		}
		string {
			g.insert_string(index, val)!
		}
	}
}

// pub fn (mut g GapBuffer) delete(cursor int, count int) {
// 	g.shift_gap_to(cursor)
// 	g.gap.end = math.min(g.gap.end + count, g.data.len)
// }

pub fn (mut g GapBuffer) delete(cursor int, count int) ! {
	g.shift_gap_to(cursor)
	g.gap.end = math.min(g.gap.end + count, g.data.len)
}

pub fn (g GapBuffer) to_string() string {
	// Only take the parts before and after the gap
	return g.get_runes().string()
}

pub fn (g GapBuffer) len() int {
	return g.data[..g.gap.start].len + g.data[g.gap.end..].len
}

pub fn (g GapBuffer) line_count() int {
	mut lines := 0
	for byte in g.to_string() {
		if byte == 10 {
			lines++
		}
	}
	lines++

	return lines
}

pub fn (g GapBuffer) line_at(i int) []rune {
	return []
}

pub fn (g GapBuffer) char_at(index int) rune {
	return g.get_runes()[index]
}

pub fn (g GapBuffer) slice(start int, end int) string {
	return g.get_runes()[start..end].string()
}

pub fn (g GapBuffer) index_to_line_col(i int) (int, int) {
	return 0, 0
}

pub fn (g GapBuffer) line_col_to_index(line int, col int) int {
	return 0
}

// splits gapbuffer into 2 ideally subsets,
// creating two separate gap buffers.
fn (g GapBuffer) split() (RopeData, RopeData) {
	text := g.get_runes()
	split := text.len / 2
	left := GapBuffer.from(text[..split])
	right := GapBuffer.from(text[split..])
	return left, right
}
