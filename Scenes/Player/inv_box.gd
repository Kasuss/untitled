extends TextureRect

var parent
var inv : Array = []
@onready var slot = %InventorySlots

func _ready() -> void:
	for c in %InventorySlots.get_child_count():
		inv.append(null)
	parent = str_to_var(name.erase(0,6))


func _get_drag_data(_at_position: Vector2) -> Variant:
	parent = str_to_var(name.erase(0,6))
	print(parent)
	var preview_texture = TextureRect.new()
	
	preview_texture.texture = texture
	preview_texture.expand_mode = 1
	preview_texture.size = Vector2(48,48)
	
	var preview = Control.new()
	preview.add_child(preview_texture)
	
	set_drag_preview(preview)
	
	
	return preview_texture.texture

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return data is Texture2D and is_in_group("Inventory")

func _drop_data(_at_position: Vector2, data: Variant) -> void:
	var new = str_to_var(name.erase(0,6))
	print(parent, " -> ", new)
	slot.get_child(parent).texture = null
	slot.get_child(new).texture = data
	#texture = data
	#var drop = name


func _on_inventory_inventory_change(_item,_icon) -> void:
	var c = _item
	for i in slot.get_child_count():
		if inv[i] == null:
			inv.pop_at(i)
			inv.insert(i,c)
			slot.get_child(i).texture = _icon
			break
		
	
