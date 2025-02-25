extends Node3D
class_name WorldGen

const SMALL = preload("res://Scenes/Environments/World1/RoomTemplates/SmallRoom.tscn")
const MED = preload("res://Scenes/Environments/World1/RoomTemplates/MediumRoom.tscn")
const BIG = preload("res://Scenes/Environments/World1/RoomTemplates/LargeRoom.tscn")

var nav = NavigationRegion3D

func ready():
	await get_tree().create_timer(2).timeout
	var rooms = %Rooms.get_children()
	for r in rooms:
		nav.new().bake_navigation_mesh()
