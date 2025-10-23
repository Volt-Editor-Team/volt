module common

// types accepted for storing in buffer
pub type InsertValue = rune | u8 | []rune | string

pub fn get_insert_value_size(val InsertValue) int {
	match val {
		rune, u8 {
			return 1
		}
		[]rune {
			return val.len
		}
		string {
			return val.runes().len
		}
	}
}
