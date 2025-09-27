module buffer

import math
import os
import time
import util.fuzzy
import fs

pub fn (mut buf Buffer) update_all_line_cache() {
	for i in 0 .. buf.lines.len {
		buf.update_line_cache(i)
	}
}

pub fn (mut buf Buffer) update_line_cache(line_index int) {
	line := buf.lines[line_index]
	mut visual := []int{len: line.len}
	mut col := 0

	for i, ch in line.runes() {
		visual[i] = col
		if ch == `\t` {
			col += buf.tabsize - (col % buf.tabsize)
		} else {
			col++
		}
	}
	buf.visual_col[line_index] = visual
}

pub fn (buf Buffer) get_visual_coords(logical_x int, logical_y int, width int) (int, int) {
	// wraps := logical_x / width
	// x := (logical_x + width) % width
	// y := logical_y + wraps
	if logical_y >= buf.visual_col.len || logical_y < 0 {
		return 0, logical_y
	}
	visual_line := buf.visual_col[logical_y]

	if logical_x >= visual_line.len {
		return if visual_line.len > 0 {
			visual_line[visual_line.len - 1] + 1, logical_y
		} else {
			0, logical_y
		}
	}
	return visual_line[logical_x], logical_y
}

pub fn (mut buf Buffer) update_visual_cursor(width int) {
	buf.visual_cursor.x, buf.visual_cursor.y = buf.get_visual_coords(buf.logical_cursor.x,
		buf.logical_cursor.y, width)
}

pub fn (buf Buffer) logical_x(logical_y int, visual_x int) int {
	if logical_y < 0 || logical_y >= buf.visual_col.len {
		return 0
	}

	visual_line := buf.visual_col[logical_y]
	mut closest := 0

	for i in 0 .. visual_line.len {
		if visual_line[i] > visual_x {
			break
		}
		closest = i
	}

	if closest == visual_line.len - 1 && visual_line[closest] < visual_x {
		return closest + 1
	}

	return closest
}

pub fn (buf Buffer) visual_y(logical_y int, visual_x int, width int) int {
	mut real_y := 0

	// sum the number of rows all previous lines take
	for row in 0 .. logical_y {
		cur_line := buf.visual_col[row]
		if cur_line.len == 0 {
			real_y++ // empty line is one row
		} else {
			// last visual column / width gives how many wraps this line takes
			real_y += (cur_line.last() / width) + 1
		}
	}

	// add wraps within the current line
	real_y += visual_x / width

	return real_y
}

pub fn (mut buf Buffer) update_offset(visual_wraps int, height int, margin int) bool {
	// Compute the cursor's relative position inside the viewport
	rel_pos := buf.logical_cursor.y - buf.row_offset + visual_wraps

	// Check if cursor is past the bottom margin
	if rel_pos >= height - margin {
		// Scroll so the cursor is `margin` lines from the bottom
		buf.row_offset = buf.logical_cursor.y + visual_wraps - (height - margin) + 1
		return true
	}
	// Check if cursor is above the top margin
	else if buf.logical_cursor.y - buf.row_offset + visual_wraps <= margin {
		// Scroll so the cursor is `margin` lines from the top
		buf.row_offset = math.max(0, buf.logical_cursor.y + visual_wraps - margin)
		return true
	}

	return false
}

pub fn (mut buf Buffer) open_fuzzy_find() {
	// if fuzzy is already running, return
	if buf.p_mode == .fuzzy {
		return
	}
	buf.temp_path = buf.path
	buf.temp_cursor = buf.logical_cursor
	buf.temp_mode = buf.p_mode

	buf.path = os.getwd()
	buf.p_mode = .fuzzy
	buf.mode = .insert

	buf.logical_cursor.x = 0
	buf.logical_cursor.y = 0
	buf.row_offset = 0
	// buf.update_visual_cursor(app.viewport.width)

	// walk path
	buf.file_ch = chan string{cap: 1000}
	go fn [mut buf] () {
		walk_path := fs.get_dir_or_parent_dir(buf.path)
		os.walk(walk_path, fn [mut buf] (file string) {
			if buf.p_mode == .fuzzy {
				if os.is_file(file) && !fuzzy.is_ignored(file) {
					buf.file_ch <- file[buf.path.len + 1..]
				}
			} else {
				buf.file_ch.close()
			}
		})
	}()

	// worker thread
	go fn [mut buf] () {
		mut last_query := ''
		mut master_list := []string{}
		for {
			if buf.p_mode != .fuzzy {
				time.sleep(100 * time.millisecond)
				continue
			}

			// non-blocking channel receive with timeout
			for {
				select {
					file := <-buf.file_ch {
						lock {
							master_list << file
							buf.temp_int = master_list.len
						}
					}
					else {
						// no file available, continue
						break
					}
				}
			}
			if buf.temp_label != last_query || buf.temp_label.len == 0 {
				last_query = buf.temp_label
				lock buf.stop_flag {
					buf.stop_flag.flag = true
				}
				lock buf.stop_flag {
					buf.stop_flag.flag = false
				}
				fuzzy.fuzzyfind(buf.temp_label, mut buf.temp_data, mut master_list, unsafe { buf.check_stop_flag })
			}
			// time.sleep(1 * time.millisecond)
		}
	}()
}
