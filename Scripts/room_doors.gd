extends MeshInstance3D

@export var door_count : int
var door = []
var to_delete = []


func _ready() -> void:
	await get_tree().create_timer(5).timeout
	check_doors()
	
func check_doors():
	while door_count > 0:
		var doorn = get_node("%door" + str(door_count))
		door.append(doorn)
		door_count -= 1
	for d in door:
		if not d.has_overlapping_areas():
			to_delete.append(d)
			continue
	await get_tree().create_timer(1).timeout
	print("penis2")
	for d in to_delete:
		var doorway = d.get_parent()
		doorway.queue_free()
