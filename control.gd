extends CharacterBody2D

# ─────────────────────────────────────────
#  PLAYER CONTROLLER — Godot 4.x
#  Requires: AnimatedSprite2D node named "AnimatedSprite2D"
#  Animations needed: "idle", "walk", "jump", "attack"
# ─────────────────────────────────────────

# Movement
@export var speed: float = 200.0
@export var jump_force: float = -450.0
@export var gravity: float = 1200.0

# Node references
@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

# Internal state
var is_attacking: bool = false
var attack_requested: bool = false


func _ready() -> void:
	# When the attack animation finishes, stop attacking
	anim.animation_finished.connect(_on_animation_finished)


func _on_animation_finished() -> void:
	if anim.animation == "attack":
		is_attacking = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
			attack_requested = true


func _physics_process(delta: float) -> void:
	_apply_gravity(delta)
	_handle_attack()
	_handle_movement()
	_handle_jump()
	move_and_slide()
	_update_animation()


# ── Gravity ───────────────────────────────
func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity * delta


# ── Horizontal movement ───────────────────
func _handle_movement() -> void:
	var direction := Input.get_axis("ui_left", "ui_right")

	if direction != 0:
		velocity.x = direction * speed
		anim.flip_h = direction < 0
	else:
		velocity.x = move_toward(velocity.x, 0, speed * 0.2)


# ── Jump ──────────────────────────────────
func _handle_jump() -> void:
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = jump_force


# ── Attack ────────────────────────────────
func _handle_attack() -> void:
	if is_attacking:
		attack_requested = false  # Ignore clicks mid-attack
		return

	if attack_requested:
		attack_requested = false
		is_attacking = true
		# Play attack once — _on_animation_finished will clear is_attacking
		anim.stop()
		anim.play("attack")


# ── Animation state machine ───────────────
func _update_animation() -> void:
	if is_attacking:
		return  # Attack anim is already playing, don't interrupt it

	if not is_on_floor():
		_play("jump")
		return

	if abs(velocity.x) > 5.0:
		_play("walk")
	else:
		_play("idle")


func _play(anim_name: StringName) -> void:
	if anim.animation != anim_name:
		anim.play(anim_name)
