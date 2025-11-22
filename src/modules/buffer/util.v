module buffer

import os
import math
import util.fuzzy
import fs
import time

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
	walk_path := fs.get_dir_or_parent_dir(path)
	first_level := os.ls(walk_path) or { [] }
	if first_level.len == 0 {
		return
	}

	// buf.temp_path = buf.path
	// buf.temp_cursor = buf.logical_cursor
	// buf.temp_mode = buf.p_mode

	buf.p_mode = .fuzzy

	// buf.logical_cursor.x = 0
	// buf.logical_cursor.y = 0
	buf.row_offset = 0
	// // buf.update_visual_cursor(app.viewport.width)

	// walk path
	buf.file_ch = chan string{cap: 1000}
	go fn [mut buf, walk_path, search_type] () {
		if buf.p_mode != .fuzzy || buf.file_ch.closed {
			return
		}
		os.walk_with_context(walk_path, &buf, fn [walk_path, search_type] (ctx voidptr, file string) {
			b := unsafe { &Buffer(ctx) }
			if b.file_ch.closed {
				return
			}
			if b.p_mode == .fuzzy {
				match search_type {
					.file {
						if os.is_file(file) && !fuzzy.is_ignored(file) {
							b.file_ch <- file[walk_path.len + 1..]
						}
					}
					.directory {
						if os.is_dir(file) && !fuzzy.is_ignored(file) {
							b.file_ch <- file[walk_path.len + 1..]
						}
					}
				}
			} else {
				b.file_ch.close()
				return
			}
		})
	}()

	time.sleep(1 * time.millisecond)
	// worker thread
	go fn [mut buf] () {
		if buf.p_mode != .fuzzy || buf.file_ch.closed {
			return
		}
		mut last_query := ''
		mut master_list := []string{}
		buf.temp_int = 0
		for {
			if buf.p_mode != .fuzzy || buf.file_ch.closed {
				return
			}

			// non-blocking channel receive with timeout
			for {
				if buf.file_ch.closed {
					return
				}
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
				fuzzy.fuzzyfind(buf.temp_label, mut buf.temp_data, mut master_list, buf.file_ch.closed)
			}
		}
	}()
}
