module list

pub fn (buf ListBuffer) char_index_to_xy(i int) (int, int) {
	mut y := 0
	mut x := i
	for line in buf.lines {
		line_len := line.len
		total_len := line_len + 1 // +1 for newline
		if x < total_len {
			if x > line_len {
				// flat index points at newline; cap x to end of line
				x = line_len
			}
			return x, y
		}
		x -= total_len
		y++
	}
	// index beyond buffer, clamp to last line
	if buf.lines.len > 0 {
		last_line_len := buf.lines[buf.lines.len - 1].len
		return last_line_len, buf.lines.len - 1
	}
	return 0, 0
}

// pub fn (buf ListBuffer) char_index_to_xy(i int) (int, int) {
// 	mut y := 0
// 	mut x := i
// 	for line in buf.lines {
// 		length := line.len + 1 // +1 for newline
// 		if x < length {
// 			return x, y
// 		}
// 		x -= length
// 		y++
// 	}
// 	return x, y
// }
