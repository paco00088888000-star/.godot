extends Camera2D

# Drag your Player node into this slot in the Inspector
@export var target: CharacterBody2D 

func _physics_process(_delta):
	if target:
		# Directly set camera position to player position
		global_position = target.global_position
