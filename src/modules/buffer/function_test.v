module buffer

// dynamic test for all buffer storage implementations
fn test_all_buffer_functions() {
	types := [BufferType.list, BufferType.rope, BufferType.gap]
	for type in types {
		buf := Buffer.from_path(type: type)
		assert typeof(buf).name == 'buffer.Buffer'

		// test insert one character
	}
}
