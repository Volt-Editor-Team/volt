module gap

fn test_insert() {
	mut buf := GapBuffer.new(GapBuffer{})
	assert buf.to_string().bytes() == []
	assert buf.debug_string() == '[gap: 0]\ncapacity: 0'
	buf.insert_char(0, `0`)
	assert buf.to_string() == '0'
	assert buf.debug_string() == '0[gap: 63]\ncapacity: 64'
	buf.insert_rune(1, `1`)
	assert buf.to_string() == '01'
	assert buf.debug_string() == '01[gap: 62]\ncapacity: 64'
	buf.insert(2, '2345678')
	assert buf.to_string() == '012345678'
	assert buf.debug_string() == '012345678[gap: 55]\ncapacity: 64'
	buf.insert(0, rune(`a`))
	assert buf.to_string() == 'a012345678'
	assert buf.debug_string() == 'a[gap: 54]012345678\ncapacity: 64'
	buf.insert(3, `9`)
	assert buf.to_string() == 'a0192345678'
	assert buf.debug_string() == 'a019[gap: 53]2345678\ncapacity: 64'
}
