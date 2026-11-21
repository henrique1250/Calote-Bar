extends CharacterBody3D

class_name Player

@onready var head: Node3D = $Head
@onready var shape_cast_3d: ShapeCast3D = $Head/Camera3D/ShapeCast3D

var MOUSE_SENS:float = 0.001

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

var input_block:bool = false

func _ready() -> void:
	add_to_group("player")
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _physics_process(delta: float) -> void:
	
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	#Criar status para não se mexer	
	if input_block:
		velocity.x = 0.0
		velocity.y = 0.0
		return

	# Pulo
	
	
	#Movimentação 
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _input(event: InputEvent) -> void:
	if input_block:
		return
	if event is InputEventMouseMotion:
		head.rotate_x(-event.relative.y * MOUSE_SENS)
		head.rotation.x = clamp(head.rotation.x, -PI/2, PI/2)
		
		rotate_y(-event.relative.x * MOUSE_SENS)
		
		
	if event is InputEventMouse:
		if Input.is_action_just_pressed("Interact"):
			if shape_cast_3d.is_colliding():
				var collided = shape_cast_3d.get_collision_result()[0]["collider"]
				if collided is PCStatic:
					input_block = true
					collided.on_toggle()
	

			
			
			
		
		
		
		
		
		
		
		
		
	
