extends Node2D

var score := 0
var is_cpu_turn := false
var cpu_turns: int  # Par ou ímpar (1 ou 2)
var symbol_attached = null
var rng = RandomNumberGenerator.new()
var main_node = null
var place_in_slot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	main_node = self.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

# Cuida da jogada da CPU em seu turno
func cpu_place_symbol():
	var counter = 0
	var slot_count = get_tree().get_node_count_in_group("navigation_buttons")
	
	while slot_count == 0:
		slot_count = get_tree().get_node_count_in_group("navigation_buttons")
		await get_tree().process_frame
		#print("0")
	
	$Thinking.start()
	main_node.get_node("Cpu_thinking_message").visible = true
	# Desativa os botões enquanto o CPU "pensa"
	for button in get_tree().get_nodes_in_group("navigation_buttons"):
		button.disabled = true
	await $Thinking.timeout
	for button in get_tree().get_nodes_in_group("navigation_buttons"):
		button.disabled = false
	main_node.get_node("Cpu_thinking_message").visible = false
	
	var chosen_slot_index = rng.randi_range(0, slot_count - 1)
	for slot in get_tree().get_nodes_in_group("navigation_buttons"):
		if chosen_slot_index == counter:
			place_in_slot = slot  # É a casa escolhida para inserir o símbolo
			break
		counter += 1
	#print(place_in_slot, chosen_slot_index)
	#print(main_node)
	main_node._button_symbol_pressed(place_in_slot, symbol_attached)
	print("CPU Played")
