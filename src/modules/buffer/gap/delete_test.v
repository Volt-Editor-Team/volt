module gap

fn test_delete_first() {
	mut buf := GapBuffer.new()
	buf.insert(0, 'this is a quick test')!
	assert buf.to_string() == 'this is a quick test'
	buf.delete(0, 1)!
	assert buf.to_string() == 'his is a quick test'
}

fn test_delete_end() {
	mut buf := GapBuffer.new()
	buf.insert(0, 'this is a quick test')!
	assert buf.to_string() == 'this is a quick test'
	buf.delete(buf.to_string().len - 1, 1)!
	assert buf.to_string() == 'this is a quick tes'
}

fn test_delete() {
	mut buf := GapBuffer.new()
	assert buf.to_string().bytes() == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_char(0, `0`)!
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
	buf.delete(0, 1)!
	assert buf.to_string() == ''
	assert buf.debug_string() == '[gap: 64]\ncapacity: 64'
	buf.delete(0, 1)!
	assert buf.to_string() == ''
	assert buf.debug_string() == '[gap: 64]\ncapacity: 64'
	buf.delete(1, 1)!
	assert buf.to_string() == ''
	assert buf.debug_string() == '[gap: 64]\ncapacity: 64'
	buf.delete(10, 5)!
	assert buf.to_string() == ''
	assert buf.debug_string() == '[gap: 64]\ncapacity: 64'
	buf.insert_rune(1, `1`)!
	assert buf.to_string() == '1'
	assert buf.debug_string() == '1[gap: 63]\ncapacity: 64'
	buf.insert(2, '2345678')!
	assert buf.to_string() == '12345678'
	assert buf.debug_string() == '12345678[gap: 56]\ncapacity: 64'
	buf.insert(0, rune(`a`))!
	assert buf.to_string() == 'a12345678'
	assert buf.debug_string() == 'a[gap: 55]12345678\ncapacity: 64'
	buf.insert(3, `9`)!
	assert buf.to_string() == 'a129345678'
	assert buf.debug_string() == 'a129[gap: 54]345678\ncapacity: 64'
}
