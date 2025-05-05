extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var knockback_strength: float = 4000.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("Player"):
		var direction = (body.global_position - global_position).normalized()
		var knockback = direction * knockback_strength
		body.take_damage(damage, knockback)
		queue_free()  # Destroy bullet
