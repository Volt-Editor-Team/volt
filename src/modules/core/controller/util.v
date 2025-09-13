module controller

pub fn logical_x(visual_col [][]int, line_index int, visual_x int) int {
	if line_index >= visual_col.len || line_index < 0 {
		return 0
	}

	visual_line := visual_col[line_index]
	mut closest := 0

	for i, col in visual_line {
		if col > visual_x {
			break
		}

		closest = i
	}

	return closest
}
