extends Node2D

@export var speed: float = 1000.0
var velocity: Vector2 = Vector2.ZERO

func _physics_process(delta):
	position += velocity * delta
