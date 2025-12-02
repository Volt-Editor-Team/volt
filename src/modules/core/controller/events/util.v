module events

// -- buffer utility --
import buffer
import util

// change_mode changes the mode of the active buffer,
// updating all necessary internal attributes
pub fn change_mode(mut buf buffer.Buffer, mode util.Mode, open_menu bool) {
	buf.change_mode(mode, open_menu)
}
