extends TextureRect


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var center = get_viewport_rect().size / 2
	position = center - Vector2(20,20)
	


