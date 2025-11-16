module controller

import os

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

pub fn update_path(path string, wd string) string {
	abs_wd := wd + os.path_separator
	abs_path := os.abs_path(path)

	if abs_path.starts_with(abs_wd) {
		return abs_path.replace(abs_wd, '')
	}

	return abs_path
}
