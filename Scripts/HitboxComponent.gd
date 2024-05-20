extends Area3D
class_name HitboxComponent

@export var health_component : HealthComponent


@warning_ignore("shadowed_variable")
func damage(damage, multiplier):
	damage = damage * multiplier
	if health_component:
		health_component.damage(damage)


