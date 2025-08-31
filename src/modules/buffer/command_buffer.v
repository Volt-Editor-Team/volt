module buffer

pub fn (mut cmd_buffer CommandBuffer) remove_char(index int) {
	cur_command := cmd_buffer.command
	// if index < 2 || index >= 2 + cur_command.len {
	// 	return
	// }
	before := if index > 0 { cur_command[..index] } else { '' }
	after := cur_command[index + 1..]
	cmd_buffer.command = before + after
}
