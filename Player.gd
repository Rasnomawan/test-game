extends KinematicBody2D

export var speed := 200
export var jump_force := 400
export var gravity := 800
export var coyote_time := 0.15     # waktu toleransi setelah jatuh
export var jump_buffer_time := 0.15 # waktu toleransi sebelum menyentuh lantai

var velocity = Vector2.ZERO
var coyote_timer = 0.0
var jump_buffer_timer = 0.0

onready var sprite = $Sprite

func _physics_process(delta):
	# Tambah gravitasi
	if not is_on_floor():
		velocity.y += gravity * delta
	else:
		coyote_timer = coyote_time  # reset coyote time kalau nyentuh lantai

	# Kurangi timer
	if coyote_timer > 0:
		coyote_timer -= delta
	if jump_buffer_timer > 0:
		jump_buffer_timer -= delta

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

	# Input lompat → buffer
	if Input.is_action_just_pressed("ui_accept"):
		jump_buffer_timer = jump_buffer_time

	# Lompat hanya kalau masih dalam coyote time DAN ada buffer input
	if jump_buffer_timer > 0 and coyote_timer > 0:
		velocity.y = -jump_force
		jump_buffer_timer = 0
		coyote_timer = 0

	# Gerakkan player
	velocity = move_and_slide(velocity, Vector2.UP)
