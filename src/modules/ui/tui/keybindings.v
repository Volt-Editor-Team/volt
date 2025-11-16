module tui

pub const normal_menu = {
	'h,j,k,l': 'cursor movement'
	':':       'open command mode'
	'space':   'menu mode'
	'f':       'open seach mode'
}
pub const insert_menu = map[string]string{}
pub const command_menu = map[string]string{}
pub const directory_menu = map[string]string{}
pub const menu_menu = {
	'f': 'open search mode (opens fuzzy in 200ms)'
}
pub const fuzzy_menu = {
	'j,k':                'move through listed files'
	'enter on file':      'open file in buffer'
	'enter on directory': 'change working directory'
}
pub const goto_menu = {
	'g': 'go to start'
	'e': 'go to end'
}
pub const search_menu = {
	'f': 'fuzzy find [FILE]'
	'd': 'fuzzy find [DIR]'
}
