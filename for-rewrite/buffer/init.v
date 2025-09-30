module buffer

pub interface Buffer {
	// --- edit functions ---
	insert(cursor int, s InsertValue)
	delete(cursor int, n int)
	to_string() string

	// --- core navigation ---
	len() int
	line_count() int
	line_at(i int)

	// --- random access ---
	char_at(i int) rune
	slice(start int, end int) string

	// --- cursor helper ---
	index_to_line_col(i int) (int, int)
	line_col_to_index(line int, col int) int
}

pub type InsertValue = rune | u8 | []rune | string
