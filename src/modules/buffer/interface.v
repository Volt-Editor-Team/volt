module buffer

import buffer.common { InsertValue }

// interface required for all buffer implementations
pub interface BufferInterface {
	to_string() string

	// --- core navigation ---
	len() int
	line_count() int
	line_at(i int) string

	// --- random access ---
	char_at(i int) rune
	slice(start int, end int) string

	// --- cursor helper ---
	index_to_line_col(i int) (int, int)
	line_col_to_index(line int, col int) int
mut:
	// --- edit functions ---
	insert(cursor int, s InsertValue) !
	delete(cursor int, n int) !
}

// interface required for cursor implementations
pub interface CursorInterface {
}

// interface specifically for RopeBuffer,
// which requires splitting ability
pub interface RopeData {
	BufferInterface
	split() (RopeData, RopeData)
}
