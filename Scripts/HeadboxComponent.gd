extends Area3D
class_name HeadboxComponent

@export var health_component : HealthComponent

func damage(attack: Damage):
	if health_component:
		health_component.crit(attack)


