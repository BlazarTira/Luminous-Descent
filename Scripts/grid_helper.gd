class_name GridHelper extends Node

# Sort the dictionary of Vector2 keys.
static func sort_vector2_keys(dict: Dictionary) -> Array:
	var keys = dict.keys()
	keys.sort_custom(GridHelper.Vector2SortHelper)
	return keys

# Helper function for sorting Vector2 keys
static func Vector2SortHelper(a: Vector2, b: Vector2) -> bool:
	if a.x == b.x:
		return a.y < b.y
	else:
		return a.x < b.x

# Check for NxN grid formation using dictionary input
static func find_nxn_grids(point_dict: Dictionary, n: int) -> Array:
	var grids := []
	
	# Sort the dictionary keys
	var sorted_keys = sort_vector2_keys(point_dict)

	# Iterate over each key to find grids
	for i in range(sorted_keys.size()):
		var grid := []
		var start_point: Variant = sorted_keys[i]

		# Check if NxN grid can be formed starting from this point
		var is_grid := true
		for x in range(n):
			for y in range(n):
				var check_point := Vector2(start_point.x + x, start_point.y + y)
				if point_dict.has(check_point):
					grid.append(check_point)
				else:
					is_grid = false
					break
			if not is_grid:
				break

		if is_grid:
			grids.append(grid)

	return grids
