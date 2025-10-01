module gap

import math
import buffer

// --- initialization ---
pub struct GapBuffer {
pub mut:
	data []rune
mut:
	gap Gap
}

struct Gap {
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

// --- buffer interface ---
// - [x] insert(cursor int, s InsertValue)
// - [x] delete(cursor int, n int)
// - [x] to_string() string
// - [ ] len() int
// - [ ] line_count() int
// - [ ] line_at(i int)
// - [ ] char_at(i int) rune
// - [ ] slice(start int, end int) string
// - [ ] index_to_line_col(i int) (int, int)
// - [ ] line_col_to_index(line int, col int) int

pub fn (mut g GapBuffer) insert(cursor int, val buffer.InsertValue) {
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

pub fn (mut g GapBuffer) delete(cursor int, count int) {
	g.shift_gap_to(cursor)
	g.gap.end = math.min(g.gap.end + count, g.data.len)
}

pub fn (g GapBuffer) to_string() string {
	// Only take the parts before and after the gap
	before := g.data[..g.gap.start]
	after := g.data[g.gap.end..]
	return before.string() + after.string()
}

pub fn (g GapBuffer) len() int {
	return g.to_string().len
}
