module buffer

// import cursor
// import fs
import cursor { LogicalCursor }
import util { Mode, PersistantMode }
import buffer.common { BufferInterface }
import buffer.list { ListBuffer }
import buffer.rope { RopeBuffer }
import buffer.gap { GapBuffer }
import fs
import os

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
	label     string = 'Scratch'
	name      string = 'Scratch'
	path      string = os.getwd()
	encoding  fs.Encoding
	prev_mode Mode           = .normal
	mode      Mode           = .normal
	p_mode    PersistantMode = .default
	// core internal structures
	type     BufferType      = .gap
	buffer   BufferInterface = ListBuffer.from_path('')
	cur_line []rune
	// cursor         CursorInterface
	cmd            CommandBuffer
	saved_cursor   LogicalCursor
	logical_cursor LogicalCursor
	file_ch        chan string
	// other important attributes
	// tabsize int
	// row_offset   int
	menu_state   bool
	needs_render bool = true
}

pub enum FuzzyType {
	none
	file
	dir
}

pub struct TempData {
pub mut:
	temp_label      string
	temp_string     string
	temp_data       [][]rune
	temp_list       []string
	temp_int        int
	temp_cursor     LogicalCursor
	temp_mode       PersistantMode
	temp_path       string
	temp_fuzzy_type FuzzyType
}

pub struct CommandBuffer {
pub mut:
	command string
}

pub fn Buffer.prefilled(buf Buffer, lines [][]rune) Buffer {
	match buf.type {
		.list {
			new_buffer := ListBuffer.prefilled(lines)
			return Buffer{
				// label:    if buf.label == 'Scratch' { buf.name } else { buf.label }
				label: buf.label
				name:  buf.name
				path:  buf.path
				// tabsize:    buf.tabsize
				encoding:   buf.encoding
				buffer:     new_buffer
				cur_line:   new_buffer.line_at(0)
				type:       buf.type
				mode:       buf.mode
				p_mode:     buf.p_mode
				menu_state: buf.menu_state
			}
		}
		.gap {
			new_buffer := GapBuffer.prefilled(lines)
			return Buffer{
				// label:    if buf.label == 'Scratch' { buf.name } else { buf.label }
				label: buf.label
				name:  buf.name
				path:  buf.path
				// tabsize:    buf.tabsize
				encoding:   buf.encoding
				buffer:     new_buffer
				cur_line:   new_buffer.line_at(0)
				type:       buf.type
				mode:       buf.mode
				p_mode:     buf.p_mode
				menu_state: buf.menu_state
			}
		}
		.rope {
			new_buffer := RopeBuffer.prefilled(lines, GapBuffer.new())
			return Buffer{
				// label:    if buf.label == 'Scratch' { buf.name } else { buf.label }
				label: buf.label
				name:  buf.name
				path:  buf.path
				// tabsize:    buf.tabsize
				encoding:   buf.encoding
				buffer:     new_buffer
				cur_line:   new_buffer.line_at(0)
				type:       buf.type
				mode:       buf.mode
				p_mode:     buf.p_mode
				menu_state: buf.menu_state
			}
		}
	}
}

pub fn Buffer.from_path(buf Buffer) Buffer {
	mut type := buf.type
	encoding := fs.detect_encoding(buf.path)
	data := os.read_bytes(buf.path) or { []u8{} }
	if data.len > 2000000 {
		type = .list
	}

	match type {
		.list {
			new_buffer := ListBuffer.from_path(buf.path)
			return Buffer{
				// label:    if buf.label == 'Scratch' { buf.name } else { buf.label }
				label: buf.label
				name:  buf.name
				path:  buf.path
				// tabsize:    buf.tabsize
				encoding:   encoding
				buffer:     new_buffer
				cur_line:   new_buffer.line_at(0)
				type:       type
				mode:       buf.mode
				p_mode:     buf.p_mode
				menu_state: buf.menu_state
			}
		}
		.gap {
			new_buffer := GapBuffer.from_path(buf.path)
			return Buffer{
				// label:    if buf.label == 'Scratch' { buf.name } else { buf.label }
				label: buf.label
				name:  buf.name
				path:  buf.path
				// tabsize:    buf.tabsize
				encoding:   encoding
				buffer:     new_buffer
				cur_line:   new_buffer.line_at(0)
				type:       type
				mode:       buf.mode
				p_mode:     buf.p_mode
				menu_state: buf.menu_state
			}
		}
		.rope {
			new_buffer := RopeBuffer.from_path(buf.path, GapBuffer.new())
			return Buffer{
				// label:    if buf.label == 'Scratch' { buf.name } else { buf.label }
				label: buf.label
				name:  buf.name
				path:  buf.path
				// tabsize:    buf.tabsize
				encoding:   encoding
				buffer:     new_buffer
				cur_line:   new_buffer.line_at(0)
				type:       type
				mode:       buf.mode
				p_mode:     buf.p_mode
				menu_state: buf.menu_state
			}
		}
	}
}
