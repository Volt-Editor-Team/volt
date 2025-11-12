module gap

import math

const max_cap = 4096
const gap_bytes = 64

fn flatten_lines(lines [][]rune) []rune {
	mut total_runes := 0
	for line in lines {
		total_runes += line.len + 1
	}
	mut runes := []rune{cap: total_runes}
	for line in lines {
		runes << line
	}

	return runes
}

fn (g GapBuffer) get_runes() []rune {
	return []rune{len: g.data.len - (g.gap.end - g.gap.start), init: if index >= g.gap.start {
		g.data[index + (g.gap.end - g.gap.start)]
	} else {
		g.data[index]
	}}
}

pub fn (g GapBuffer) debug_string() string {
	before := g.data[..g.gap.start]
	after := g.data[g.gap.end..]
	gap_len := g.gap.end - g.gap.start
	capacity := g.data.cap - gap_len - (before.len + after.len)
	return '${before.string()}[gap: ${gap_len}]${after.string()}\ncapacity: ${capacity}'
}

// gap memcpy
fn (mut g GapBuffer) shift_gap_to(curs int) {
	gap_len := g.gap.end - g.gap.start
	cursor := math.min(math.max(curs, 0), g.data.len - gap_len)
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
fn (mut g GapBuffer) check_gap_size(n_required int) {
	gap_len := g.gap.end - g.gap.start
	// more gap is needed
	if gap_len < n_required {
		g.shift_gap_to(g.data.len - gap_len)
		// reallocation is required
		if g.data.cap < g.data.len + n_required {
			minimum_allocation := g.data.len + n_required + gap_bytes
			generous_allocation := g.data.len * 2
			g.data.grow_cap(math.max(minimum_allocation, math.min(max_cap, generous_allocation)))
		}
		// increase length (growing gap) by minimum gap_bytes or as many as neccessary
		unsafe { g.data.grow_len(math.max(gap_bytes, n_required)) }
		g.gap.end = g.data.len
	}
}
