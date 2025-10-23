module buffer

// import cursor
// import fs
import util { Mode, PersistantMode }

pub enum BufferType {
	gap
	rope
	list
	// tree
}

// ! this struct is NOT being used currently ! it is under development !
// buffer must adhere to BufferInterface and CursorInterface
pub struct Buffer {
	TempData
pub mut:
	// public attributes
	label  string         = 'Scratch'
	name   string         = 'Scratch'
	path   string         = 'Scratch'
	mode   Mode           = .normal
	p_mode PersistantMode = .default
	// core used for internal functionality
	type         BufferType
	buffer       BufferInterface
	cursor       CursorInterface
	saved_cursor CursorInterface
	file_ch      chan string
}

pub struct TempData {
pub mut:
	temp_label  string
	temp_data   []string = []
	temp_int    int
	temp_cursor CursorInterface
	temp_mode   PersistantMode
	temp_path   string
}

pub struct CommandBuffer {
pub mut:
	command string
}
