module list

import fs { read_file }
import buffer.common { InsertValue }

pub struct ListBuffer {
pub mut:
	lines [][]rune = [][]rune{len: 1}
}

pub fn ListBuffer.from_path(path string) ListBuffer {
	lines := read_file(path) or { [][]rune{len: 1} }
	mut buf := ListBuffer{
		lines: lines
	}
	return buf
}

pub fn ListBuffer.prefilled(lines [][]rune) ListBuffer {
	mut buf := ListBuffer{
		lines: lines
	}
	return buf
}

// --- buffer interface ---
// - [?] insert(cursor int, s InsertValue)
// - [x] delete(cursor int, n int)
// - [x] to_string() string
// - [x] len() int
// - [x] line_count() int
// - [x] line_at(i int)
// - [ ] char_at(i int) rune
// - [ ] slice(start int, end int) string
// - [ ] index_to_line_col(i int) (int, int)
// - [ ] line_col_to_index(line int, col int) int
// - [ ] split() (RopeData, RopeData)
// - [x] replace_with_temp(lines []string)

pub fn (mut buf ListBuffer) insert(curs int, s InsertValue) ! {
	// return error('')
	x, y := buf.char_index_to_xy(curs)
	match s {
		rune {
			if s == `\n` {
				buf.insert_newline(x, y)
			} else {
				buf.insert_char(x, y, s)
			}
		}
		u8 {
			return
		}
		string {
			for r in s.runes_iterator() {
				buf.insert_char(x, y, r)
			}
		}
		[]string {
			return
		}
		[]rune {
			buf.insert_lines(y + 1, s)
		}
	}
	// ch := s as rune
	// if ch == `\n` {
	// 	buf.insert_newline(x,y)
	// } else {
	// 	buf.insert_char(x, y, ch.str())
	// }
}

pub fn (mut buf ListBuffer) delete(curs int, n int) ! {
	x, y := buf.char_index_to_xy(curs)
	buf.remove_char(x, y)
}

pub fn (buf ListBuffer) to_string() string {
	return buf.lines.map(it.string()).join('\n')
}

pub fn (buf ListBuffer) len() int {
	mut res := 0
	for line in buf.lines {
		res += line.len
	}
	return res
}

pub fn (buf ListBuffer) line_count() int {
	return buf.lines.len
}

pub fn (buf ListBuffer) line_at(i int) []rune {
	return buf.lines[i]
}

pub fn (buf ListBuffer) char_at(i int) rune {
	return rune(` `)
}

pub fn (buf ListBuffer) slice(start int, end int) string {
	return ''
}

pub fn (buf ListBuffer) index_to_line_col(i int) (int, int) {
	return 1, 1
}

pub fn (buf ListBuffer) line_col_to_index(line int, col int) int {
	return 0
}

pub fn (mut buf ListBuffer) replace_with_temp(lines [][]rune) {
	buf.lines = lines
}
