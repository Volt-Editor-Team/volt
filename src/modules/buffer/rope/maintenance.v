module rope

const balance_constant = 1.5

fn (mut n RopeNode) check_rebalance() &RopeNode {
	left, right := n.get_weights()
	// rotate left
	if left > balance_constant * f32(right) {
		// check if left-left or left-right imbalance
		left_left, left_right := n.left.get_weights()
		if left_right > balance_constant * f32(left_left) {
			// LR
			n.left = n.left.rotate_left()
		}
		// LL
		return n.rotate_right()
	}

	// rotate right
	if right > balance_constant * f32(left) {
		// check if right-right or right-left imbalance
		right_left, right_right := n.right.get_weights()
		if right_left > balance_constant * f32(right_right) {
			// RL
			n.right = n.right.rotate_right()
		}
		// RR
		return n.rotate_left()
	}
	return n
}

fn (n &RopeNode) get_weights() (int, int) {
	mut left_weight := 0
	mut right_weight := 0
	if n.left != unsafe { nil } {
		left_weight = n.left.weight
	}
	if n.right != unsafe { nil } {
		right_weight = n.right.weight
	}

	return left_weight, right_weight
}

fn (mut n RopeNode) rotate_left() &RopeNode {
	if n.right == unsafe { nil } {
		return n
	}
	mut new_root := n.right
	n.right = new_root.left
	new_root.left = n

	new_root.weight = new_root.left.total_len()
	n.weight = n.left.total_len()

	return new_root
}

fn (mut n RopeNode) rotate_right() &RopeNode {
	if n.left == unsafe { nil } {
		return n
	}
	mut new_root := n.left
	n.left = new_root.right
	new_root.right = n

	new_root.weight = new_root.left.total_len()
	n.weight = n.left.total_len()

	return new_root
}

fn (mut node RopeNode) check_split(node_cap int) ! {
	if node.left != unsafe { nil } || node.right != unsafe { nil } {
		return error('No node to check')
	} else {
		if node.data == none {
			return error('Invalid Node')
		} else {
			// split current node and remove data -- this node is no longer a leaf
			if node.data.len() > node_cap {
				left, right := node.data.split()
				node.data = none
				node.left = &RopeNode{
					data: left
				}
				node.right = &RopeNode{
					data: right
				}
				node.weight = left.len()
			}

			// recursive check left to split
			if node.left != unsafe { nil } {
				if data := node.left.data {
					if data.len() > node_cap {
						node.left.check_split(node_cap)!
					}
				}
			}

			// recursive check right to split
			if node.right != unsafe { nil } {
				if data := node.right.data {
					if data.len() > node_cap {
						node.right.check_split(node_cap)!
					}
				}
			}
		}
	}
}
