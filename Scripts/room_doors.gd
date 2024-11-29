extends MeshInstance3D

@export var door_count : int
var door = []
var to_delete = []
var doorway


func _ready() -> void:
	await get_tree().create_timer(1).timeout
	check_doors()
	
func check_doors():
	while door_count > 0:
		var doorn = get_node("%door" + str(door_count))
		door.append(doorn)
		door_count -= 1
	for d in door:
		if d.has_overlapping_areas():
			doorway = d.get_parent()
			doorway.operation = 0
			continue
		to_delete.append(d)
			
	await get_tree().create_timer(1).timeout
	print("penis2")
	for d in to_delete:
		doorway = d.get_parent()
		doorway.queue_free()
