extends CharacterBody2D

@export_group("Kretanje")
@export var walk_speed: float = 200.0
@export var run_multiplier: float = 3.0
@export var acceleration: float = 0.2

@export_group("Meat Boy Skok")
@export var jump_force: float = -550.0      # Snaga punog skoka
@export var jump_cut_value: float = 0.2     # Koliko brzine ostaje kad pustiš tipku (0.3 = 30%)
@export var gravity: float = 1800.0         # Jaka gravitacija za "snappy" osjećaj

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	# 1. GRAVITACIJA
	if not is_on_floor():
		velocity.y += gravity * delta
	
	# 2. INPUT KRETANJE (Walk/Run)
	var move_dir = Input.get_axis("ui_left", "ui_right")
	var is_running = Input.is_action_pressed("ui_shift") # Trebaš "ui_shift" u Input Mapu
	
	var target_speed = move_dir * walk_speed * (run_multiplier if is_running else 1.0)
	velocity.x = lerp(velocity.x, target_speed, acceleration)
	
	if move_dir != 0:
		anim.flip_h = move_dir < 0

	# 3. SKOK LOGIKA
	# Početak skoka
	if is_on_floor() and Input.is_action_just_pressed("ui_accept"):
		velocity.y = jump_force

	# JUMP CUT: Ako pustiš Space dok se još penješ, brzina se drastično smanjuje
	if Input.is_action_just_released("ui_accept") and velocity.y < 0:
		velocity.y *= jump_cut_value

	# 4. KRETANJE I ANIMACIJE
	move_and_slide()
	_handle_animations(move_dir, is_running)

func _handle_animations(move_dir: float, is_running: bool) -> void:
	if not is_on_floor():
		_play("jump")
	elif abs(velocity.x) > 10.0:
		if is_running and anim.sprite_frames.has_animation("run"):
			_play("run")
		else:
			_play("walk")
	else:
		_play("idle")

func _play(anim_name: String) -> void:
	if anim.sprite_frames.has_animation(anim_name):
		if anim.animation != anim_name:
			anim.play(anim_name)
