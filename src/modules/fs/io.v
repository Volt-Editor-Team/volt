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
