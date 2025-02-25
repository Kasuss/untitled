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
	for g in Global.wep_id:
		var w = load(Global.wep_id[g])
		print(w)
		if w.Rarity == 0:
			w.Rarity = 60
		
		if w.Rarity == 60:
			commons.append(w)
		elif w.Rarity == 25:
			rares.append(w)
		else:
			epics.append(w)
			
	for p in Global.item_id:
		var w = load(Global.item_id[p])
		if w.Rarity == 0:
			w.Rarity = 60
			
		if w.Rarity == 60:
			commons.append(w)
		elif w.Rarity == 25:
			rares.append(w)
		else:
			epics.append(w)

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
