extends StaticBody3D

class_name PCStatic
var player:Player
var is_using = false

@onready var camera_3d: Camera3D = $Camera3D
@onready var sub_viewport: SubViewport = $SubViewport
@onready var pc_controler: Control = $SubViewport/PCControler

func _ready() -> void:
	player = get_tree().get_first_node_in_group("player")


func on_toggle():
	is_using = !is_using
	camera_3d.current = is_using
	

func _input(event: InputEvent) -> void:
	if !is_using:
		return
	
	if event is InputEventKey:
		if Input.is_action_just_pressed("Voltar"):
			on_toggle()
			player.input_block = false
		else:
			sub_viewport.push_input(event)
			
	elif event is InputEventMouseButton:
		
		if event.button_index == MOUSE_BUTTON_LEFT or event.button_index == MOUSE_BUTTON_MIDDLE:
			var mouse_event = InputEventMouseButton.new()
			mouse_event.button_index = event.button_index
			mouse_event.pressed = event.pressed
			mouse_event.position = pc_controler.pc_mouse_pos
			mouse_event.global_position = pc_controler.pc_mouse_pos	
			
			sub_viewport.push_input(mouse_event)
			
	elif event is InputEventMouseMotion:
		pc_controler.pc_mouse_pos += event.relative
		pc_controler.pc_mouse_pos.x = clamp(pc_controler.pc_mouse_pos.x, 0.0, sub_viewport.size.x  - 10.0)
		pc_controler.pc_mouse_pos.y = clamp(pc_controler.pc_mouse_pos.y, 0.0, sub_viewport.size.y  - 10.0)
		pc_controler.update_cursor_pos()	
			
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
		
				
			
