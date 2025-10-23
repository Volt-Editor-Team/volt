module buffer

// import cursor
// import fs
// import util

// interface required for all buffer implementations
pub interface Buffer {
	to_string() string

	// --- core navigation ---
	len() int
	line_count() int
	line_at(i int) []rune

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

// interface specifically for RopeBuffer,
// which requires splitting ability
pub interface RopeData {
	Buffer
	split() (RopeData, RopeData)
}

pub type InsertValue = rune | u8 | []rune | string

pub fn get_insert_value_size(val InsertValue) int {
	match val {
		rune, u8 {
			return 1
		}
		[]rune {
			return val.len
		}
		string {
			return val.runes().len
		}
	}
}

pub struct CommandBuffer {
pub mut:
	command string
}
