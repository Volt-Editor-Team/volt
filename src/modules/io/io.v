module io

import os

pub fn read_file(path string) ![]string {
	abs_path := os.real_path(path)

	if os.exists(abs_path) {
		if os.is_file(abs_path) && os.is_readable(abs_path) {
			return os.read_lines(abs_path) or { [''] }
		} else {
			return error('Unable to read file')
		}
	} else {
		return error('Could not find file')
	}
}

pub fn write_file(path string, buffer []string) bool {
	abs_path := os.abs_path(path)

	if os.exists(abs_path) {
		if os.is_file(abs_path) && os.is_writable(abs_path) {
			os.write_lines(path, buffer) or { return false }
			return true
		} else {
			return false
		}
	} else {
		os.create(abs_path) or { return false }
		if os.is_file(abs_path) && os.is_writable(abs_path) {
			os.write_lines(path, buffer) or { return false }
			return true
		} else {
			return false
		}
	}
}
