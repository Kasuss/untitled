extends CanvasLayer

@onready var ammo = [%HeavyAmmo, %MedAmmo, %SmallAmmo]
@onready var c = %InventorySlots.get_children()

signal inventory_change

var paused = false
var inventory : Array = []

func _ready() -> void:
	for i in c:
		inventory.append(i)
	print(inventory)

func _on_weapons_update_ammo(_mag, _reserves, _ammo) -> void:
	var a = [_ammo["Light"], _ammo["Medium"], _ammo["Heavy"]]
	var o = 0
	for x in ammo:
		x.text = "x " + str(a[o])
		o += 1
	o = 0

func _input(event):
	if event.is_action_pressed("backpack"):
		if paused == false:
			%InventoryAnim.play("inventory_up")
			paused = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CONFINED)
			get_tree().paused = true
		else:
			%InventoryAnim.play("inventory_down")
			paused = false
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			get_tree().paused = false
	
	
			

func _on_weapons_item_pickup(_item, _icon) -> void:
	inventory.append(_item)
	inventory_change.emit(_item, _icon)
