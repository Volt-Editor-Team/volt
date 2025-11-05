module rope

import buffer.common { InsertValue, RopeData }

// --- initialization ---
pub struct RopeBuffer {
mut:
	root     &RopeNode = unsafe { nil }
	node_cap int       = 4096 // number of chacters in leaf before splitting
}

@[heap]
pub struct RopeNode {
pub mut:
	left   &RopeNode = unsafe { nil }
	right  &RopeNode = unsafe { nil }
	weight int // number of characters in left subtree
	data   ?RopeData
}

pub fn RopeBuffer.new(b RopeData) RopeBuffer {
	mut rope := RopeBuffer{}
	rope.root = &RopeNode{
		data: b
	}
	return rope
}

// --- buffer interface ---
// - [ ] insert(cursor int, s InsertValue)
// - [ ] delete(cursor int, n int)
// - [ ] to_string() string
// - [ ] len() int
// - [ ] line_count() int
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

pub fn line_count() int {
	return 0
}

pub fn line_at(i int) string {
	return ''
}

pub fn char_at(i int) rune {
	return rune(` `)
}

pub fn slice(start int, end int) string {
	return ''
}

pub fn index_to_line_col(i int) (int, int) {
	return 0, 0
}

pub fn line_col_to_index(line int, col int) int {
	return 0
}
