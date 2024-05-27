extends Node3D

signal item_drop

@export_category("Weapon Resources")
@export var guns: Array[Resource]
@export var pickups: Array[Resource]

var commons : Array
var rares : Array
var epics : Array

func _ready():
	randomize()
	for g in guns:
		if g.Rarity == 0:
			g.Rarity = 60
		
		if g.Rarity == 60:
			commons.append(g)
		elif g.Rarity == 25:
			rares.append(g)
		else:
			epics.append(g)
			
	for p in pickups:
		print(p.Rarity)
		if p.Rarity == 0:
			p.Rarity = 60
			
		if p.Rarity == 60:
			commons.append(p)
		elif p.Rarity == 25:
			rares.append(p)
		else:
			epics.append(p)

func item_dropped():
	var roll = randi_range(1,100)
	var item
	var type
	#Common Drop
	if roll <= 60:
		print("common, " + str(roll))
		var all = commons.size()
		if all < 1:
			return null
		item = commons[randi_range(0,all-1)]
		type = item.Type
		return [item, type]
	#Rare Drop
	elif roll <= 85:
		print("rare, " + str(roll))
		var all = rares.size()
		if all < 1:
			return null
		item = rares[randi_range(0,all-1)]
		type = item.Type
		return [item, type]
	#Epic Drop
	else:
		print("epic, " + str(roll))
		var all = epics.size()
		if all < 1:
			return null
		elif all == 1:
			return epics[0]
		item = epics[randi_range(0,all-1)]
		type = item.Type
		return [item, type]
