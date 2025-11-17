module tui

pub struct Command {
	name    string
	aliases []string
	desc    string
}

pub const normal_menu = {
	'!':       'toggle menu'
	'h,j,k,l': 'cursor movement'
	':':       'open command mode'
	'space':   'menu mode'
	'f':       'open seach mode'
}
pub const insert_menu = map[string]string{}
pub const command_menu = [
	Command{
		name:    'quit'
		aliases: ['q']
		desc:    'close application'
	},
	Command{
		name:    'help'
		aliases: ['h']
		desc:    'open help document'
	},
	Command{
		name:    'change-directory'
		aliases: ['cd']
		desc:    'change directory. If no argument is provided, opens directory buffer'
	},
	Command{
		name:    'close-buffer'
		aliases: ['cb']
		desc:    'closes the current buffer'
	},
	Command{
		name:    'print-working-directory'
		aliases: ['pwd']
	},
	Command{
		name:    'doctor'
		aliases: ['doc']
		desc:    'display useful information about this system'
	},
	Command{
		name:    'fuzzy-find'
		aliases: ['fzf', 'fuzzy']
		desc:    'opens fuzzy find for files in current working directory'
	},
	Command{
		name:    'buffer_type'
		aliases: ['btype']
		desc:    'display the storage type being used by current buffer'
	},
]
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
