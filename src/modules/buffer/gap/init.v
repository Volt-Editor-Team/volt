module gap

import math
import buffer.common { InsertValue, RopeData }
import fs { read_file_runes }

// --- initialization ---
pub struct GapBuffer {
mut:
	data       []rune
	gap        Gap
	line_count int
	line_cache []int = [0]
}

struct Gap {
mut:
	start int
	end   int
}

pub fn GapBuffer.new() GapBuffer {
	return GapBuffer{
		line_count: 1
	}
}

pub fn GapBuffer.from(data []rune) GapBuffer {
	return GapBuffer{
		data:       []rune{len: data.len, cap: math.min(max_cap, 2 * data.len), init: data[index]}
		gap:        Gap{
			start: data.len
			end:   data.len
		}
		line_count: calculate_num_lines(data)
	}
}

pub fn GapBuffer.from_path(path string) GapBuffer {
	data := read_file_runes(path) or { []rune{} }
	return GapBuffer{
		data:       []rune{len: data.len, cap: math.min(max_cap, 2 * data.len), init: data[index]}
		gap:        Gap{
			start: data.len
			end:   data.len
		}
		line_count: calculate_num_lines(data)
	}
}

pub fn GapBuffer.prefilled(lines []string) GapBuffer {
	// data, num_lines := util.flatten_lines(lines)
	data := lines.join_lines().runes()
	return GapBuffer{
		data:       []rune{len: data.len, cap: math.min(max_cap, 2 * data.len), init: data[index]}
		gap:        Gap{
			start: data.len
			end:   data.len
		}
		line_count: data.len
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
// - [ ] split() (RopeData, RopeData)
// - [ ] replace_with_temp(lines []string)

pub fn (mut g GapBuffer) insert(index int, val InsertValue) ! {
	match val {
		rune {
			g.insert_rune(index, val)!
			if val == `\n` {
				g.line_count++
			}
		}
		u8 {
			g.insert_char(index, val)!
			if val == u8(`\n`) {
				g.line_count++
			}
		}
		[]rune {
			g.insert_runes(index, val)!
			// 1) Find new lines
			for _, r in val {
				if r == `\n` {
					g.line_count++
				}
			}
		}
		string {
			g.insert_string(index, val)!
			for _, v in val {
				if v == `\n` {
					g.line_count++
				}
			}
		}
		[]string {}
	}
}

pub fn (mut g GapBuffer) delete(cursor int, count int) ! {
	g.shift_gap_to(cursor)
	end := math.min(g.gap.end + count, g.data.len)
	for i in g.gap.end .. end {
		if g.data[i] == `\n` {
			g.line_count--
			for idx, _ in g.line_cache {
				if idx <= i {
					g.line_cache[idx]--
				}
			}
		}
	}
	g.gap.end = math.min(g.gap.end + count, g.data.len)
}

pub fn (g GapBuffer) to_string() string {
	// Only take the parts before and after the gap
	return g.get_runes().string()
}

pub fn (g GapBuffer) len() int {
	return g.data.len - (g.gap.end - g.gap.start) - 1
}

pub fn (g GapBuffer) line_count() int {
	return g.line_count
}

pub fn (g GapBuffer) line_at(line_index int) []rune {
	runes := g.get_runes()
	if runes.len == 0 || line_index < 0 {
		return []rune{}
	}

	mut current_line := 0
	mut start := 0

	// find start of requested line
	for start < runes.len && current_line < line_index {
		if runes[start] == `\n` {
			current_line++
		}
		start++
	}

	if current_line != line_index {
		// requested line does not exist
		return []rune{}
	}

	mut end := start
	for end < runes.len && runes[end] != `\n` {
		end++
	}
	return runes[start..end]
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

pub fn (mut g GapBuffer) replace_with_temp(lines [][]rune) {
	mut runes := []rune{}
	for line in lines {
		runes << line
	}
	g.data = runes
	g.gap.start = runes.len
	g.gap.end = runes.len
}

// splits gapbuffer into 2 ideally subsets,
// creating two separate gap buffers.
pub fn (g GapBuffer) split() (RopeData, RopeData) {
	text := g.get_runes()
	split := text.len / 2
	left := GapBuffer.from(text[..split])
	right := GapBuffer.from(text[split..])
	return left, right
}

// clear contents
pub fn (mut g GapBuffer) clear() {
	g.data = []
	g.line_count = 0
	g.gap.start = 0
	g.gap.end = 0
}

pub fn (g GapBuffer) last() int {
	return g.line_at(g.line_count).len
}
