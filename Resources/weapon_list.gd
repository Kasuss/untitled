extends Node3D

signal item_drop

@export_category("Weapon Resources")
@export var guns: Array[Resource]

var item_rarities : Dictionary
var commons : Array
var rares : Array
var epics : Array

func _ready():
	randomize()
	for g in guns:
		if g.Rarity == 60 or 0:
			commons.append(g)
		elif g.Rarity == 25:
			rares.append(g)
		else:
			epics.append(g)

func item_dropped():
	var roll = randi_range(1,100)
	var result
	#Common Drop
	if roll <= 60:
		print("common")
		var all = commons.size()
		result = randi_range(0,all)
		return result
	#Rare Drop
	elif roll <= 85:
		print("rare")
		var all = rares.size()
		result = randi_range(0,all)
		return result
	#Epic Drop
	else:
		print("epic")
		var all = epics.size()
		result = randi_range(0,all)
		return result
