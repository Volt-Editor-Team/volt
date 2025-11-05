module list

pub fn (buf ListBuffer) char_index_to_xy(i int) (int, int) {
	mut y := 0
	mut x := i
	for line in buf.lines {
		length := line.runes().len + 1 // +1 for newline
		if x < length {
			return x, y
		}
		x -= length
		y++
	}
	return x, y
}
