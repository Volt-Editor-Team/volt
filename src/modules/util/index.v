module util

// pub fn get_char_and_width(ch rune, index int, tabsize int) (rune, int) {
// 	if ch == `\t` {
// 		return ` `, tabsize - (index % tabsize)
// 	}

// 	return ch, 1
// }

pub fn binary_insert[T](mut arr []T, item T, compare fn (T, T) int) {
	mut low := 0
	mut high := arr.len

	for low < high {
		mid := low + (high - low) / 2
		difference := compare(item, arr[mid])

		if difference < 0 {
			low = mid + 1
		} else {
			high = mid
		}
	}

	arr.insert(low, item)
}

pub fn is_subsequence(query string, text string) bool {
	mut i := 0
	mut j := 0
	for i < query.len && j < text.len {
		if query[i] == text[j] {
			i++
		}
		j++
	}
	return i == query.len
}
