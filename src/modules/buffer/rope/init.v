module rope

import buffer.common { InsertValue, RopeData }
import fs { read_file_runes }
import util

// --- initialization ---
pub struct RopeBuffer {
mut:
	root     &RopeNode = unsafe { nil }
	node_cap int       = 4096 // number of chacters in leaf before splitting
}

@[heap]
pub struct RopeNode {
pub mut:
	left       &RopeNode = unsafe { nil }
	right      &RopeNode = unsafe { nil }
	weight     int // number of characters in left subtree
	line_count int
	data       ?RopeData
}

pub fn RopeBuffer.new(b RopeData) RopeBuffer {
	mut rope := RopeBuffer{}
	rope.root = &RopeNode{
		data: b
	}
	return rope
}

pub fn RopeBuffer.prefilled(lines []string, b RopeData) RopeBuffer {
	// data, _ := util.flatten_lines(lines)
	data := lines
	mut rope := RopeBuffer{}
	rope.root = &RopeNode{
		data: b
	}
	rope.insert(0, data) or { return rope }
	return rope
}

pub fn RopeBuffer.from_path(path string, b RopeData) RopeBuffer {
	data := read_file_runes(path) or { []rune{} }
	mut rope := RopeBuffer{}
	rope.root = &RopeNode{
		data: b
	}
	rope.insert(0, data) or { return rope }
	return rope
}

// --- buffer interface ---
// - [x] insert(cursor int, s InsertValue)
// - [x] delete(cursor int, n int)
// - [x] to_string() string
// - [x] len() int
// - [x] line_count() int
// - [ ] line_at(i int)
// - [ ] char_at(i int) rune
// - [ ] slice(start int, end int) string
// - [ ] index_to_line_col(i int) (int, int)
// - [ ] line_col_to_index(line int, col int) int

pub fn (mut r RopeBuffer) insert(cursor int, s InsertValue) ! {
	r.root = r.root.insert(cursor, s, 0, r.node_cap)!
}

pub fn (mut r RopeBuffer) delete(cursor int, n int) ! {
	r.root = r.root.delete(cursor, n, 0, r.node_cap)!
}

pub fn (r RopeBuffer) to_string() string {
	mut res := ''
	mut nodes := []&RopeNode{}
	in_order(r.root, mut nodes)
	for node in nodes {
		if data := node.data {
			res += data.to_string()
		}
	}
	return res
}

pub fn (r RopeBuffer) len() int {
	return r.root.total_len()
}

pub fn (r RopeBuffer) node_count() int {
	return r.root.node_count()
}

pub fn (r RopeBuffer) leaf_count() int {
	return r.root.leaf_count()
}

pub fn (r RopeBuffer) line_count() int {
	return r.root.line_count()
}

pub fn (r RopeBuffer) line_at(line_idx int) []rune {
	// like weight traversal tree using line_count
	// then use ropedata nodes line_at
	// node := r.root.find_line(line_idx) or { return [] }
	// if node.data != none {
	// 	return node.data.line_at(node.line_count - line_idx)
	// }
	// return []
	mut leaves := []&RopeNode{}
	in_order(r.root, mut leaves)

	mut cum_lines := 0
	for node in leaves {
		if mut data := node.data {
			if cum_lines + data.line_count() > line_idx {
				// line_idx is inside this leaf
				mut adjusted_index := line_idx - cum_lines
				return data.line_at(adjusted_index)
			}
			cum_lines += data.line_count()
		}
	}

	// line_idx out of bounds
	return []
}

pub fn (r RopeBuffer) char_at(i int) rune {
	return rune(` `)
}

pub fn (r RopeBuffer) slice(start int, end int) string {
	return ''
}

pub fn (r RopeBuffer) index_to_line_col(i int) (int, int) {
	return 0, 0
}

pub fn (r RopeBuffer) line_col_to_index(line int, col int) int {
	return 0
}

pub fn (mut r RopeBuffer) replace_with_temp(lines [][]rune) {
	if r.root != unsafe { nil } {
		if r.root.left == unsafe { nil } {
			r.root.left = unsafe { nil }
		}
		if r.root.right == unsafe { nil } {
			r.root.right = unsafe { nil }
		}
		if r.root.data != none {
			r.root.data.clear()
			r.root.weight = 0
			data, _ := util.flatten_lines(lines)
			r.root = r.root.insert(0, data, 0, r.node_cap) or { return }
		}
	}
}
