extends Node2D

var adjacency := {}
var node_map := {}

func _draw():
	# Dibuja cada arista
	for a in adjacency.keys():
		for b in adjacency[a]:
			if node_map.has(a) and node_map.has(b):
				var pa = node_map[a].position
				var pb = node_map[b].position
				draw_line(pa, pb, Color(0, 1, 1), 2.0)
