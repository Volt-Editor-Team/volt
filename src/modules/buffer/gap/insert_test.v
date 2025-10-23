module gap

import os

// simple test for each insert function
fn test_insert_char_one() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_char(0, `0`)!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
}

fn test_insert_char_end() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_char(0, `0`)!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
	buf.insert_char(1, `1`)!
	assert buf.to_string() == '01'
	assert buf.debug_string() == '01[gap: 62]\ncapacity: 64'
}

fn test_insert_rune_one() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_char(0, `0`)!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
}

fn test_insert_rune_end() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_rune(0, `0`)!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
	buf.insert_rune(1, `1`)!
	assert buf.to_string() == '01'
	assert buf.debug_string() == '01[gap: 62]\ncapacity: 64'
}

fn test_insert_runes_list_one() {
	str := 'helloworld'
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_runes(0, str[0..1].runes())!
	assert buf.to_string() == 'h'
	assert buf.debug_string() == 'h[gap: 63]\ncapacity: 64'
}

fn test_insert_runes_list_end() {
	str := 'helloworld'
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_runes(0, str[0..1].runes())!
	assert buf.to_string() == 'h'
	assert buf.debug_string() == 'h[gap: 63]\ncapacity: 64'
	buf.insert_runes(1, str[1..6].runes())!
	assert buf.to_string() == 'hellow'
	assert buf.debug_string() == 'hellow[gap: 58]\ncapacity: 64'
}

fn test_insert_string_one() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_string(0, '0')!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
}

fn test_insert_string_end() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_string(0, '0')!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
	buf.insert_string(1, '1')!
	assert buf.to_string() == '01'
	assert buf.debug_string() == '01[gap: 62]\ncapacity: 64'
}

fn test_insert_emoji_one() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert(0, `🌎`)!
	assert buf.to_string() == '🌎'
	assert buf.debug_string() == '🌎[gap: 63]\ncapacity: 64'
}

fn test_insert_emoji_end() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert(0, `🌎`)!
	assert buf.to_string() == '🌎'
	assert buf.debug_string() == '🌎[gap: 63]\ncapacity: 64'
	buf.insert(1, `🌎`)!
	assert buf.to_string() == '🌎🌎'
	assert buf.debug_string() == '🌎🌎[gap: 62]\ncapacity: 64'
}

// testing edge cases
fn test_insert_out_of_bounds_larger() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert(10000, `🌎`)!
	assert buf.to_string() == '🌎'
	assert buf.debug_string() == '🌎[gap: 63]\ncapacity: 64'
}

fn test_insert_out_of_bounds_smaller() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert(-10000, `🌎`)!
	assert buf.to_string() == '🌎'
	assert buf.debug_string() == '🌎[gap: 63]\ncapacity: 64'
}

// mix and match different insert functions
fn test_insert() {
	mut buf := GapBuffer.new()
	assert buf.data == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_char(0, `0`)!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
	buf.insert_rune(1, `1`)!
	assert buf.to_string() == '01'
	assert buf.debug_string() == '01[gap: 62]\ncapacity: 64'
	buf.insert(2, '2345678')!
	assert buf.to_string() == '012345678'
	assert buf.debug_string() == '012345678[gap: 55]\ncapacity: 64'
	buf.insert(0, rune(`a`))!
	assert buf.to_string() == 'a012345678'
	assert buf.debug_string() == 'a[gap: 54]012345678\ncapacity: 64'
	buf.insert(3, `9`)!
	assert buf.to_string() == 'a0192345678'
	assert buf.debug_string() == 'a019[gap: 53]2345678\ncapacity: 64'
}

fn test_insert_from_file() {
	mut buf := GapBuffer.new()
	str := os.read_file(os.real_path(os.join_path('.', 'src', 'modules', 'buffer', 'gap',
		'insert_test.v'))) or { '' }
	buf.insert(0, str)!
	assert buf.len() == str.runes().len
}
