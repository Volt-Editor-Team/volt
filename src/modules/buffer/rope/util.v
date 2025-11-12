module rope

import buffer.common { InsertValue, get_insert_value_size }
import math

pub fn (r RopeBuffer) left() !&RopeNode {
	if r.root == unsafe { nil } {
		return error('root node is not initialized')
	}

	if r.root.left == unsafe { nil } {
		return error('no left child exists')
	}

	return r.root.left
}

fn all_nodes(node &RopeNode, mut res []&RopeNode) {
	if node.left != unsafe { nil } {
		in_order(node.left, mut res)
	}

	res << node

	if node.right != unsafe { nil } {
		in_order(node.right, mut res)
	}
}

fn in_order(node &RopeNode, mut res []&RopeNode) {
	if node.left != unsafe { nil } {
		in_order(node.left, mut res)
	}

	if node.data != none {
		res << node
	}

	if node.right != unsafe { nil } {
		in_order(node.right, mut res)
	}
}

fn (n &RopeNode) get_node(weight int) !&RopeNode {
	if n.left == unsafe { nil } && n.right == unsafe { nil } {
		return unsafe { n }
	} else {
		if weight < n.weight {
			if n.left == unsafe { nil } {
				return error('Invalid tree state: expected left node')
			}
			return n.left.get_node(weight)
		} else {
			if n.right == unsafe { nil } {
				return error('Invalid tree state: expected right node')
			}
			return n.right.get_node(weight)
		}
	}
}

fn (n &RopeNode) total_len() int {
	if n == unsafe { nil } {
		return 0
	}
	if n.left == unsafe { nil } && n.right == unsafe { nil } {
		if n.data != none {
			return n.data.len()
		}
		return 0
	} else {
		mut total := 0
		if n.left != unsafe { nil } {
			total += n.left.total_len()
		}
		if n.right != unsafe { nil } {
			total += n.right.total_len()
		}
		return total
	}
}

fn (n &RopeNode) find_line(line_idx int) !&RopeNode {
	if n.left == unsafe { nil } && n.right == unsafe { nil } {
		return unsafe { n }
	} else {
		if line_idx < n.line_count {
			if n.left == unsafe { nil } {
				return error('Invalid tree state: expected left node')
			}
			return n.left.find_line(line_idx)
		} else {
			if n.right == unsafe { nil } {
				return error('Invalid tree state: expected right node')
			}
			return n.right.find_line(line_idx)
		}
	}
}

fn (n &RopeNode) line_count() int {
	if n == unsafe { nil } {
		return 0
	}
	if n.left == unsafe { nil } && n.right == unsafe { nil } {
		if n.data != none {
			return n.data.line_count()
		}
		return 0
	} else {
		mut total := 0
		if n.left != unsafe { nil } {
			total += n.left.line_count()
		}
		if n.right != unsafe { nil } {
			total += n.right.line_count()
		}
		return total - 1
	}
}

fn (n &RopeNode) leaf_count() int {
	if n.left == unsafe { nil } && n.right == unsafe { nil } {
		if n.data != none {
			return 1
		}
		return 0
	} else {
		mut total := 0
		if n.left != unsafe { nil } {
			total += n.left.leaf_count()
		}
		if n.right != unsafe { nil } {
			total += n.right.leaf_count()
		}
		return total
	}
}

fn (n &RopeNode) node_count() int {
	if n == unsafe { nil } {
		return 0
	}
	mut total := 1 // count this node
	if n.left != unsafe { nil } {
		total += n.left.node_count()
	}
	if n.right != unsafe { nil } {
		total += n.right.node_count()
	}
	return total
}

fn (mut r RopeNode) insert(pos int, val InsertValue, offset int, node_cap int) !&RopeNode {
	// if r.left == unsafe { nil } && r.right == unsafe { nil } {
	// 	if r.data == none {
	// 		return error('Invalid Node')
	// 	} else {
	// 		index := pos - offset
	// 		r.data.insert(index, val)!
	// 		r.check_split(node_cap)!
	// 		// r.line_count = r.data.line_count()
	// 	}
	if r.left == unsafe { nil } && r.right == unsafe { nil } {
		if mut data := r.data {
			index := pos - offset
			data.insert(index, val)!
			r.check_split(node_cap)!
			r.line_count = data.line_count()
		} else {
			return error('Invalid Node: missing data')
		}
	} else {
		if pos < r.weight {
			r.weight += get_insert_value_size(val)
			if r.left == unsafe { nil } {
				return error('Invalid tree state: expected left node')
			}
			r.left.insert(pos, val, offset, node_cap)!
		} else {
			if r.right == unsafe { nil } {
				return error('Invalid tree state: expected right node')
			}
			r.right.insert(pos, val, r.weight, node_cap)!
		}
		r.line_count = r.left.line_count() + r.right.line_count()
	}
	return r.check_rebalance()
}

fn (mut r RopeNode) delete(pos int, num int, offset int, node_cap int) !&RopeNode {
	if r.left == unsafe { nil } && r.right == unsafe { nil } {
		if r.data == none {
			return error('Invalid Node')
		} else {
			index := pos - offset
			r.data.delete(index, num)!
			r.weight = r.data.len()
		}
	} else {
		if pos < r.weight {
			if r.left == unsafe { nil } {
				return error('Invalid tree state: expected left node')
			}
			r.weight = r.left.total_len()
			r.left.delete(pos, num, offset, node_cap)!
		} else {
			if r.right == unsafe { nil } {
				return error('Invalid tree state: expected right node')
			}
			r.right.delete(pos, num, r.weight, node_cap)!
		}
	}
	return r.check_rebalance()
}
