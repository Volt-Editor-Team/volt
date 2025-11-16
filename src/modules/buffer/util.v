module buffer

import os
import math
import util.fuzzy
import fs

pub enum SearchType {
	file
	directory
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

pub fn (mut buf Buffer) open_fuzzy_find(path string, search_type SearchType) {
	// if fuzzy is already running, return
	if buf.p_mode == .fuzzy {
		return
	}
	buf.temp_path = buf.path
	buf.temp_cursor = buf.logical_cursor
	buf.temp_mode = buf.p_mode

	// buf.path = os.getwd()
	buf.p_mode = .fuzzy
	buf.mode = .insert

	buf.logical_cursor.x = 0
	buf.logical_cursor.y = 0
	buf.row_offset = 0
	// buf.update_visual_cursor(app.viewport.width)

	// walk path
	buf.file_ch = chan string{cap: 1000}
	go fn [mut buf, path, search_type] () {
		walk_path := fs.get_dir_or_parent_dir(path)
		os.walk_with_context(walk_path, &buf, fn [path, search_type] (ctx voidptr, file string) {
			b := unsafe { &Buffer(ctx) }
			if b.p_mode == .fuzzy {
				match search_type {
					.file {
						if os.is_file(file) && !fuzzy.is_ignored(file) {
							b.file_ch <- file[path.len + 1..]
						}
					}
					.directory {
						if os.is_dir(file) && !fuzzy.is_ignored(file) {
							b.file_ch <- file[path.len + 1..]
						}
					}
				}
			} else {
				b.file_ch.close()
				return
			}
		})
	}()

	// worker thread
	go fn [mut buf] () {
		mut last_query := ''
		mut master_list := []string{}
		buf.temp_int = 0
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
