module main

import gap { GapBuffer }

fn main() {
	mut buf := GapBuffer.new(GapBuffer{})
	println('test 1 ${buf.data.string()}')
	buf.insert_char(0, `0`)
	println('test 2 ${buf.data.string()}')
	buf.insert_rune(1, `1`)
	println('test 3 ${buf.data.string()}')
	buf.insert(2, '2345678')
	println('test 4 ${buf.data.string()}')
	buf.insert(0, rune(`a`))
	println('test 5 ${buf.data.string()}')
	buf.insert(3, `n`)
	println('test 6 ${buf.data}')
}
