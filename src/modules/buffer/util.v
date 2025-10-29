module buffer

import os
import math
import util.fuzzy
import fs

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
				return
			}
		})
	}()

	// worker thread
	go fn [mut buf] () {
		mut last_query := ''
		mut master_list := []string{}
		for {
			if buf.p_mode != .fuzzy {
				return
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
				fuzzy.fuzzyfind(buf.temp_label, mut buf.temp_data, mut master_list)
			}
			// time.sleep(1 * time.millisecond)
		}
	}()
}
