extends PathFollow2D

@export var speed: float = 80.0
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _physics_process(delta):
	progress += speed * delta
