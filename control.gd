extends CharacterBody2D

# ─────────────────────────────────────────
#  PLAYER CONTROLLER — Godot 4.x
#  Requires: AnimatedSprite2D node named "AnimatedSprite2D"
#  Animations needed: "idle", "walk", "jump", "attack", "e1", "e2"
#
#  Controls:
#    LMB      → attack
#    button2  → e1   (map in Project > Input Map)
#    button3  → e2   (map in Project > Input Map)
# ─────────────────────────────────────────

# Movement
@export var speed: float = 200.0
@export var jump_force: float = -450.0
@export var gravity: float = 1200.0

# Node references
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var is_attacking: bool = false
var current_attack: String = ""


func _ready() -> void:
	anim.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if anim.animation in ["attack", "e1", "e2"]:
		is_attacking = false
		current_attack = ""


func _input(event: InputEvent) -> void:
	if is_attacking:
		return

	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			_start_attack("attack")
			return

	if event.is_action_pressed("button2"):
		_start_attack("e1")
	elif event.is_action_pressed("button3"):
		_start_attack("e2")


func _start_attack(anim_name: String) -> void:
	is_attacking = true
	current_attack = anim_name
	# Directly set frame and play — bypasses any loop state
	anim.stop()
	anim.frame = 0
	anim.play(anim_name)
	# Ensure looping off after play() since play() can re-apply SpriteFrames settings
	anim.sprite_frames.set_animation_loop(anim_name, false)


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_movement()
	_handle_jump()
	move_and_slide()

	# Check BEFORE _update_animation so we don't override a finished attack
	if is_attacking and not anim.is_playing():
		is_attacking = false
		current_attack = ""

	_update_animation()


func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


func _handle_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction != 0:
		velocity.x = direction * speed
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.2)


func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force


func _update_animation() -> void:
	# Hard gate — never touch the animation while attacking
	if is_attacking:
		return

	if not is_on_floor():
		_play("jump")
	elif abs(velocity.x) > 5.0:
		_play("walk")
	else:
		_play("idle")


func _play(anim_name: StringName) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)
