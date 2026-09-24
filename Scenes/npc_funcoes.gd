extends CharacterBody3D

class_name NpcGeneric

@export var destination_npc: Array = []
@export var pontos_interacao: Array = []
@export var sentar_offset_time: float = 0.5

@onready var animation_player: AnimationPlayer = find_child("AnimationPlayer", true, false)
@onready var navigation_agent: NavigationAgent3D = find_child("NavigationAgent3D", true, false)
@onready var idle_timer: Timer = find_child("Timer", true, false)
@onready var interaction_timer: Timer = find_child("InteractionTimer", true, false)

@export var marker_saida: Array = []      
@export var tempo_sentado: float = 10.0  
@export var offset_sentar: Vector3 = Vector3(0, -0.078, 0)

@export var anim_idle: StringName = "idle"
@export var anim_walk: StringName = "walk"
@export var anim_sit: StringName = "sit"

@onready var copo: Area3D = $AreaCopo
@onready var cachaca: CanvasLayer = $AreaCopo/Ui_Minigame_Cachaca

enum NPC_States {
	Idle,
	Walking,
	Interact
}

var heading_to_interaction: bool = false
var heading_to_exit: bool = false
var SPEED: float = 2.0
var current_state: NPC_States
var current_destinition: Marker3D
var walk_count: int = 0
const WALKS_BEFORE_INTERACTION := 3


func _ready() -> void:
	_set_state(NPC_States.Idle)
	destination_npc = get_tree().get_nodes_in_group("pontos_andar")
	pontos_interacao = get_tree().get_nodes_in_group("pontos_interacao")
	marker_saida = get_tree().get_nodes_in_group("ponto_saida")


func _set_state(new_state: NPC_States) -> void:
	current_state = new_state

	match current_state:
		NPC_States.Idle:
			animation_player.play(anim_idle)
			idle_timer.start(1.0 + randf())
		NPC_States.Walking:
			animation_player.play(anim_walk)
		NPC_States.Interact:
			_sentar_na_cadeira()
			EventBus.npc_iniciou_interacao.emit(self)


func _physics_process(_float) -> void:
	match current_state:
		NPC_States.Idle:
			pass
		NPC_States.Walking:
			var next_path_posi: Vector3 = navigation_agent.get_next_path_position()
			velocity = global_position.direction_to(next_path_posi) * SPEED
			var look_at_target: Vector3 = Vector3(next_path_posi.x, global_position.y, next_path_posi.z)
			if not global_position.is_equal_approx(look_at_target):
				look_at(look_at_target)
		NPC_States.Interact:
			velocity = Vector3.ZERO

	move_and_slide()

func _on_timer_timeout() -> void:
	decide_next_stage()

func decide_next_stage() -> void:
	if current_state == NPC_States.Idle:
		move_to_marker()
		_set_state(NPC_States.Walking)

func move_to_marker() -> void:
	if destination_npc.is_empty():
		push_warning("destination_npc está vazio em %s" % name)
		return
	current_destinition = destination_npc.pick_random()
	navigation_agent.target_position = current_destinition.global_position

func _on_destination_reached() -> void:
	velocity = Vector3.ZERO
	
	if heading_to_exit:
		heading_to_exit = false
		queue_free()
		return

	if heading_to_interaction:
		heading_to_interaction = false
		_set_state(NPC_States.Interact)
		return
		
	walk_count += 1

	if walk_count >= WALKS_BEFORE_INTERACTION and pontos_interacao.size() > 0:
		walk_count = 0
		var marker: Marker3D = pontos_interacao.pick_random()
		current_destinition = marker
		navigation_agent.target_position = marker.global_position
		heading_to_interaction = true
		current_state = NPC_States.Walking
	elif destination_npc.size() > 0:
		var marker: Marker3D = destination_npc.pick_random()
		current_destinition = marker
		navigation_agent.target_position = marker.global_position
		current_state = NPC_States.Walking

func _sentar_na_cadeira() -> void:
	if current_destinition == null:
		return

	var marker_sentar: Marker3D = current_destinition
	var posicao_final: Vector3 = marker_sentar.global_position + offset_sentar

	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(self, "global_position", posicao_final, sentar_offset_time)
	tween.tween_property(self, "global_rotation", marker_sentar.global_rotation, sentar_offset_time)
	tween.chain().tween_callback(func():
		var anim: Animation = animation_player.get_animation(anim_sit)
		if anim:
			anim.loop_mode = Animation.LOOP_NONE
		animation_player.play(anim_sit)
		interaction_timer.start()
	)

	copo.mostrar_objeto()
		

func _on_navigation_agent_3d_navigation_finished() -> void:
	_on_destination_reached()


func _on_interaction_timer_timeout() -> void:
	if current_state != NPC_States.Interact:
		return

	if marker_saida.is_empty():
		push_warning("marker_saida está vazio em %s" % name)
		return
	
	EventBus.npc_finalizou_interacao.emit(self)

	if(!cachaca.game_win):
		cachaca.falha()
	
	await get_tree().create_timer(2.0).timeout

	var saida: Marker3D = marker_saida.pick_random()
	current_destinition = saida
	navigation_agent.target_position = saida.global_position
	heading_to_exit = true
	_set_state(NPC_States.Walking)


func _on_navigation_agent_3d_target_reached() -> void:
	pass # Replace with function body.
