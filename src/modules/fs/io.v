module fs

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

pub fn get_working_dir_paths() []string {
	current_path := os.abs_path('.')
	entries := os.ls(current_path) or { [] }
	return entries
}
