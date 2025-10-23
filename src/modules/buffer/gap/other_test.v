module gap

fn test_line_count() {
	mut buf := GapBuffer.new()
	assert buf.line_count() == 1
	buf.insert(0, 'hello\nworld\n')!
	assert buf.line_count() == 3
	buf.delete(11, 1)!
	assert buf.to_string() == 'hello\nworld'
	assert buf.line_count() == 2
}

fn test_char_at() {
	mut buf := GapBuffer.new()
	buf.insert(0, 'hello world!')!
	assert buf.char_at(5) == ` `
	buf.insert(5, ' 🌎')!
	assert buf.to_string() == 'hello 🌎 world!'
	assert buf.char_at(6) == rune(`🌎`)
	assert buf.char_at(7) == ` `
}

fn test_split() {
	mut buf := GapBuffer.new()
	buf.insert(0, 'hello world!')!
	assert buf.char_at(5) == ` `
	left, right := buf.split()
	test_left := left as GapBuffer
	test_right := right as GapBuffer
	assert test_left.data.cap == 12
	assert test_left.data.len == 6
	assert test_left.gap.start == 6
	assert test_left.gap.end == 6
	assert test_left.data == [`h`, `e`, `l`, `l`, `o`, ` `]
	assert test_left.to_string() == 'hello '
	assert test_left.debug_string() == 'hello [gap: 0]\ncapacity: 6'
	assert test_right.to_string() == 'world!'
	assert test_right.debug_string() == 'world![gap: 0]\ncapacity: 6'
}
