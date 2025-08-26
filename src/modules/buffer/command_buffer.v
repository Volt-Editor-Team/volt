module buffer

pub fn (mut cmd_buffer CommandBuffer) remove_char(index int) {
	cur_command := cmd_buffer.command
	before := if index > 0 { cur_command[..index - 1] } else { '' }
	after := cur_command[index..]
	cmd_buffer.command = before + after
}
