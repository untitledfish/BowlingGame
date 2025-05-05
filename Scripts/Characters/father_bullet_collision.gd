extends Area2D

@export var speed: float = 300.0
@export var damage: int = 10
@export var knockback_strength: float = 4000.0
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
		get_parent().velocity = Vector2.ZERO
		$CollisionShape2D.disabled = false
		get_parent().get_node("Explosion").visible = true
		await get_tree().create_timer(1).timeout
		$CollisionShape2D.disabled = true
		get_parent().get_node("Explosion").visible = false
		queue_free()  # Destroy bullet
		
	else:
		get_parent().velocity = Vector2.ZERO
		$CollisionShape2D.disabled = false
		get_parent().get_node("Explosion").visible = true
		await get_tree().create_timer(1).timeout
		$CollisionShape2D.disabled = true
		get_parent().get_node("Explosion").visible = false
		queue_free()
