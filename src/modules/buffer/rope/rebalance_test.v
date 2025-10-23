module rope

import gap

fn test_rebalance_rotations() {
	// 1. Construct an unbalanced left-heavy tree
	mut r := RopeBuffer.new(gap.GapBuffer.new())

	r.root.weight = 30

	r.root.left = &RopeNode{
		weight: 20
		data:   gap.GapBuffer.new()
	}

	r.root.left.left = &RopeNode{
		weight: 10
		data:   gap.GapBuffer.new()
	}

	assert r.root.node_count() == 3
	assert r.root.weight == 30
	assert r.root.left != unsafe { nil }
	assert r.root.right == unsafe { nil }
	assert r.root.left.node_count() == 2
	assert r.root.right.node_count() == 0

	// 2. Force rebalance on the root
	r.root = r.root.check_rebalance()

	// 3. Verify a rotation occurred
	assert r.root.left != unsafe { nil } // should still have children
	assert r.root.right != unsafe { nil }

	// extra check
	assert r.root.node_count() == 3
	assert r.root.left.node_count() == 1
	// the left-left node should now be thw left node
	// weight shouldn't have changed since we didn't change its children
	assert r.root.left.weight == 10
	assert r.root.right.node_count() == 1

	// mut nodes := []&RopeNode{}
	// in_order(r.root, mut nodes)
	// assert nodes == []
}
