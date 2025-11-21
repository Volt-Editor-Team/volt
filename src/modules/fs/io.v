module fs

import os

pub enum Encoding {
	utf8
	utf16le
	utf16be
}

pub fn detect_encoding(data []u8) Encoding {
	if data.len >= 2 {
		if data[0] == 0xFF && data[1] == 0xFE {
			return .utf16le
		}
		if data[0] == 0xFE && data[1] == 0xFF {
			return .utf16be
		}
	}
	return .utf8
}

fn decode_utf16le(data []u8) string {
	mut runes := []rune{}
	mut i := 2 // skip 0xFF 0xFE BOM

	for i + 1 < data.len {
		low := u16(data[i])
		high := u16(data[i + 1])
		unit := (high << 8) | low
		i += 2

		// Handle surrogate pairs
		if unit >= 0xD800 && unit <= 0xDBFF && i + 1 < data.len {
			low2 := u16(data[i])
			high2 := u16(data[i + 1])
			unit2 := (high2 << 8) | low2

			if unit2 >= 0xDC00 && unit2 <= 0xDFFF {
				i += 2
				codepoint := 0x10000 + ((unit - 0xD800) << 10) + (unit2 - 0xDC00)
				runes << rune(codepoint)
				continue
			}
		}

		// Normal BMP character
		runes << rune(unit)
	}

	return runes.string()
}

fn load_text_file(path string) !string {
	data := os.read_bytes(path)!
	encoding := detect_encoding(data)

	return match encoding {
		.utf16le { decode_utf16le(data) }
		.utf16be { 'UTF-16 BE not implemented yet' }
		.utf8 { data.bytestr() }
	}
}

pub fn read_file_runes(path string) ![]rune {
	abs_path := os.real_path(path)

	if os.exists(abs_path) {
		if os.is_file(abs_path) && os.is_readable(abs_path) {
			// lines := os.read_file(abs_path) or { '' }
			lines := load_text_file(abs_path) or { '' }
			return lines.runes()
		} else {
			return error('Unable to read file')
		}
	} else {
		return error('Could not find file')
	}
}

pub fn read_file_lines(path string) ![][]rune {
	abs_path := os.real_path(path)

	if os.exists(abs_path) {
		if os.is_file(abs_path) && os.is_readable(abs_path) {
			str := load_text_file(abs_path) or { '' }
			lines := str.split_into_lines()
			return [][]rune{len: lines.len, init: lines[index].runes()}
		} else {
			return error('Unable to read file')
		}
	} else {
		return error('Could not find file')
	}
}

pub fn write_file(path string, buffer []string) (bool, string) {
	// build absolute path
	abs_path := os.abs_path(path)

	// create file if it doesn't already exist
	if !os.exists(abs_path) {
		os.create(abs_path) or { return false, 'Unable to create file: ${abs_path}' }
	}

	// if path isn't a file, return error message
	if !os.is_file(abs_path) {
		return false, 'Path is not a file: ${abs_path}'
	}

	// if path isn't writable, return error message
	if !os.is_writable(abs_path) {
		return false, 'File is not writable: ${abs_path}'
	}

	// write to file
	// handle error immediately if something went wrong
	os.write_lines(path, buffer) or { return false, 'Unable to write to file: ${abs_path}' }

	// successfully wrote to file. no need to return a message
	return true, ''
}

pub fn get_working_dir() string {
	return os.abs_path('.') + os.path_separator
}

pub fn get_working_dir_paths() (string, []string) {
	current_path := get_working_dir()
	mut entries := os.ls(current_path) or { [''] }
	entries = entries.map(if is_dir(it) {
		it + os.path_separator
	} else {
		it
	})
	return current_path, entries
}

pub fn get_paths_from_parent_dir(path string) (string, []string) {
	trimmed_path := path.trim_right(os.path_separator)
	parent_dir_path := os.dir(trimmed_path)
	base_path := parent_dir_path + os.path_separator
	mut entries := os.ls(parent_dir_path) or { [''] }
	entries = entries.map(if is_dir(base_path + it) { it + os.path_separator } else { it })
	return base_path, entries
}

pub fn get_paths_from_dir(base_path string, dir string) (string, []string) {
	dir_path := base_path + dir
	mut entries := os.ls(dir_path) or { [''] }
	entries = entries.map(if is_dir(dir_path + it) { it + os.path_separator } else { it })
	return dir_path, entries
}

pub fn path_exists(path string) bool {
	abs_path := os.abs_path(path)
	return os.exists(abs_path)
}

pub fn is_dir(path string) bool {
	abs_path := os.abs_path(path)
	if os.exists(abs_path) && os.is_dir(abs_path) {
		return true
	}
	return false
}

pub fn get_dir_or_parent_dir(base_path string) string {
	mut path := base_path
	if !is_dir(path) {
		path = os.dir(path)
	}

	return path
}
