module gap

fn test_insert() {
	mut buf := GapBuffer.new(GapBuffer{})
	assert buf.data.string() == ''
	buf.insert_char(0, `0`)
	assert buf.data.string() == '0'
	buf.insert_rune(1, `1`)
	assert buf.data.string() == '01'
	buf.insert(2, '2345678')
	assert buf.data.string() == '012345678'
	buf.insert(0, rune(`a`))
	assert buf.data.string() == 'a012345678'
}
