extends CharacterBody2D

@export var gravity: float = 1200.0
@export var max_fall_speed: float = 400.0
@export var speed: float = 100.0
@export var bullet_scene: PackedScene
@export var fire_rate: float = 1.0
@onready var sprite = $Sprite2D
@onready var detection_area = $DetectionRange
@onready var muzzle = $Muzzle
@onready var fireRate = $Firerate

const Bullet = preload("res://Scripts/Characters/grunt_bullet.gd")

var player: Node2D = null
var player_detected: bool = false

func _ready():
	detection_area.body_entered.connect(_on_body_entered)
	detection_area.body_exited.connect(_on_body_exited)
	fireRate.timeout.connect(_on_fireRate_timeout)

func _physics_process(delta):
	# Apply gravity to the vertical velocity
	velocity.y += gravity * delta
	velocity.y = min(velocity.y, max_fall_speed)
	if player_detected and player:
		var to_player = player.global_position - global_position
		# Move only in the X direction to follow player
		velocity.x = to_player.normalized().x * speed
		# Flip to face player
		sprite.scale.x = abs(sprite.scale.x) * -sign(to_player.x)
		# Flip muzzle position based on direction
		var muzzle_offset = abs(muzzle.position.x)
		muzzle.position.x = muzzle_offset * -sign(sprite.scale.x)
	else:
		velocity.x = 0.0
	move_and_slide()


func _on_body_entered(body):
	if body.is_in_group("Player"):
		player = body
		player_detected = true
		fireRate.start()

func _on_body_exited(body):
	if body == player:
		player_detected = false
		player = null
		fireRate.stop()

func shoot_at_player():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = muzzle.global_position
	# Determine direction based on sprite flip (assumes facing left by default)
	var direction = Vector2.LEFT if sprite.scale.x > 0 else Vector2.RIGHT
	bullet.velocity = direction * bullet.speed
	get_tree().current_scene.add_child(bullet)


func _on_fireRate_timeout():
	if player_detected and player:
		shoot_at_player()
