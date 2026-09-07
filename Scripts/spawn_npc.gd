extends Node3D
@export var npc_scene: Array[PackedScene] = []
@export var spawn_on_start: bool = true
@export var spawn_interval:float = 5.0
@export var max_npc = 10
@export var spawned_count:int = 1
@onready var timer: Timer = $Timer
@export var occupied_radius: float = 1.0  # raio pra considerar um ponto "ocupado"
@onready var spawn_points: Array[Marker3D] = []

@export var meta_npcs: int = 10           # valor da meta que dispara a troca de cena
@export var cena_final: PackedScene       # arraste a cena de destino aqui no Inspector

func _ready() -> void:
	
	for child in get_children():
		if child is Marker3D:
			spawn_points.append(child)
	
	timer.wait_time = spawn_interval
	timer.timeout.connect(_on_spawn_timer_timeout)
	timer.start()
	
	if spawn_on_start:
		spawn_npc()
		
func _on_spawn_timer_timeout() -> void:
	if spawned_count > max_npc:
		timer.stop()
		return
	
	spawn_npc()
	_check_meta()
	spawned_count += 1

func _check_meta() -> void:
	if spawned_count >= meta_npcs:
		timer.stop()
		if cena_final:
			get_tree().change_scene_to_packed(cena_final)
		else:
			push_warning("Meta atingida, mas 'cena_final' não foi atribuída no Inspector!")

func spawn_npc() -> void:
	if npc_scene.is_empty():
		push_warning("Nenhuma cena de NPC atribuída no Spawner!")
		return
	var scene_to_spawn: PackedScene = npc_scene.pick_random()
	var npc_instance = scene_to_spawn.instantiate() as CharacterBody3D
	npc_instance.global_transform = global_transform
	get_parent().add_child.call_deferred(npc_instance)
	
func _get_free_spawn_point() -> Marker3D:
	# embaralha pra não sempre tentar na mesma ordem
	var shuffled := spawn_points.duplicate()
	shuffled.shuffle()
	for point in shuffled:
		if not _is_point_occupied(point):
			return point
	return null
func _is_point_occupied(point: Marker3D) -> bool:
	for npc in get_tree().get_nodes_in_group("npc"):
		if npc.global_position.distance_to(point.global_position) < occupied_radius:
			return true
	return false
