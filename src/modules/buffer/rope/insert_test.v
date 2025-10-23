module rope

import gap
import os

fn test_insert() {
	mut buf := RopeBuffer.new(gap.GapBuffer.new())
	buf.insert(0, 'hello world')!
	assert buf.to_string() == 'hello world'
	assert buf.len() == 11
}

fn test_insert_causes_split() {
	mut buf := RopeBuffer{
		root:     &RopeNode{
			data: gap.GapBuffer.new()
		}
		node_cap: 2
	}
	buf.insert(0, 'hello world')!
	assert buf.leaf_count() == 7
	assert buf.node_count() == 13
}

fn test_insert_from_file() {
	mut buf := RopeBuffer.new(gap.GapBuffer.new())
	str := os.read_file(os.real_path(os.join_path('.', 'src', 'modules', 'buffer', 'gap',
		'insert_test.v'))) or { '' }
	buf.insert(0, str)!
	assert buf.len() == str.runes().len
	assert buf.to_string() == str
	assert buf.leaf_count() == 2
	assert buf.node_count() == 3
}

fn test_insert_from_file_with_smaller_cap() {
	mut buf := RopeBuffer{
		root:     &RopeNode{
			data: gap.GapBuffer.new()
		}
		node_cap: 1000
	}
	str := os.read_file(os.real_path(os.join_path('.', 'src', 'modules', 'buffer', 'gap',
		'insert_test.v'))) or { '' }
	buf.insert(0, str)!
	assert buf.len() == str.runes().len
	assert buf.to_string() == str

	// this will need to be changes once tree balancing is implemented
	assert buf.leaf_count() == 8
	assert buf.node_count() == 15
}
