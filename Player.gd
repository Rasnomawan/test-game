extends KinematicBody2D

export var speed := 200
export var jump_force := 400
export var gravity := 900

var velocity = Vector2.ZERO
onready var sprite = $Sprite

func _physics_process(delta):
	# Tambah gravitasi
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		velocity.y = 0

	# Input kiri/kanan
	var input_dir = 0
	if Input.is_action_pressed("ui_left"):
		input_dir -= 1
	if Input.is_action_pressed("ui_right"):
		input_dir += 1
	velocity.x = input_dir * speed

	# Balik sprite sesuai arah gerak
	if input_dir != 0:
		sprite.flip_h = input_dir < 0

	# Lompat
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = -jump_force

	# Gerakkan player
	velocity = move_and_slide(velocity, Vector2.UP)
