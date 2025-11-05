module buffer

// import cursor
// import fs
import cursor { LogicalCursor }
import util { Mode, PersistantMode }
import buffer.common { BufferInterface }
import buffer.list { ListBuffer }

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
	// core internal structures
	type   BufferType      = .list
	buffer BufferInterface = ListBuffer.from_path('')
	// cursor         CursorInterface
	saved_cursor   LogicalCursor
	logical_cursor LogicalCursor
	file_ch        chan string
	// other important attributes
	tabsize    int
	row_offset int
}

pub struct TempData {
pub mut:
	temp_label  string
	temp_data   []string = []
	temp_int    int
	temp_cursor LogicalCursor
	temp_mode   PersistantMode
	temp_path   string
}

pub struct CommandBuffer {
pub mut:
	command string
}

pub fn Buffer.prefilled(buf Buffer, lines []string) Buffer {
	match buf.type {
		.list {
			new_buffer := ListBuffer.prefilled(lines)
			return Buffer{
				label:   if buf.label == 'Scratch' { buf.name } else { buf.label }
				name:    buf.name
				path:    buf.path
				tabsize: buf.tabsize
				buffer:  new_buffer
				mode:    buf.mode
				p_mode:  buf.p_mode
			}
		}
		else {
			new_buffer := ListBuffer.prefilled(lines)
			return Buffer{
				label:   if buf.label == 'Scratch' { buf.name } else { buf.label }
				name:    buf.name
				path:    buf.path
				tabsize: buf.tabsize
				buffer:  new_buffer
				mode:    buf.mode
				p_mode:  buf.p_mode
			}
		}
	}
}

pub fn Buffer.from_path(buf Buffer) Buffer {
	match buf.type {
		.list {
			new_buffer := ListBuffer.from_path(buf.path)
			return Buffer{
				label:   if buf.label == 'Scratch' { buf.name } else { buf.label }
				name:    buf.name
				path:    buf.path
				tabsize: buf.tabsize
				buffer:  new_buffer
				mode:    buf.mode
				p_mode:  buf.p_mode
			}
		}
		else {
			new_buffer := ListBuffer.from_path(buf.path)
			return Buffer{
				label:   if buf.label == 'Scratch' { buf.name } else { buf.label }
				name:    buf.name
				path:    buf.path
				tabsize: buf.tabsize
				buffer:  new_buffer
				mode:    buf.mode
				p_mode:  buf.p_mode
			}
		}
	}
}
