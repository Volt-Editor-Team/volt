module gap

import math

const max_cap = 4096
const gap_bytes = 64

pub fn calculate_num_lines(runes []rune) int {
	mut lines := 1
	for r in runes {
		if r == `\n` {
			lines++
		}
	}
	if runes.len > 0 && runes[runes.len - 1] == `\n` {
		lines--
	}
	return lines
}

pub fn (g GapBuffer) get_runes() []rune {
	mut temp := g.data[..g.gap.start]
	temp << g.data[g.gap.end..]
	return temp
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
