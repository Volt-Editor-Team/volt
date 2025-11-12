module rope

import buffer.gap
import buffer.list
import os

fn test_compare_to_list_buffer() {
	path := os.real_path(os.join_path('.', 'src', 'modules', 'buffer', 'gap', 'insert_test.v'))
	str := os.read_file(path) or { '' }
	mut buf := RopeBuffer.from_path(path, gap.GapBuffer.new())
	mut list_buf := list.ListBuffer.from_path(path)
	assert buf.len() == list_buf.len()
	// assert buf.line_at(161) == [`\n`]
	assert buf.line_count() == list_buf.line_count()
	assert buf.line_at(1) == list_buf.line_at(1)
	assert buf.line_at(150) == list_buf.line_at(150)
}
