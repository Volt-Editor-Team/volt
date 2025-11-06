module common

pub type StartValue = string | []string | []rune

// types accepted for storing in buffer
pub type InsertValue = rune | u8 | []rune | string | []string

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
		[]string {
			mut total := 0
			for line in val {
				total += line.runes().len
			}
			return total
		}
	}
}

pub struct DeleteResult {
pub mut:
	joined_line bool
	new_x       int
}
