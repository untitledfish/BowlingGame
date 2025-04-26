extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var knockback_strength: float = 6000.0
var velocity: Vector2 = Vector2.ZERO

func _ready():
	body_entered.connect(_on_body_entered)

func _physics_process(delta):
	position += velocity * delta

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var direction = (body.global_position - global_position).normalized()
		var knockback = direction * knockback_strength
		body.take_damage(damage, knockback)
		queue_free()  # Destroy bullet
