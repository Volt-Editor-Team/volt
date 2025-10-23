module rope

import gap

fn test_delete() {
	mut buf := RopeBuffer.new(gap.GapBuffer.new())
	buf.insert(0, 'hello world')!
	assert buf.to_string() == 'hello world'
	buf.delete(0, 1)!
	assert buf.to_string() == 'ello world'
	buf.delete(4, 5)!
	assert buf.to_string() == 'ellod'
}
