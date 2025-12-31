extends Area2D

var main_node

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Hidden/Hidden.grab_focus()
	main_node = self.get_parent()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_novo_jogo_mouse_entered() -> void:
	$CanvasLayer/Novo_jogo/Novo_jogo.grab_focus()


func _on_como_jogar_mouse_entered() -> void:
	$CanvasLayer/Como_jogar/Como_jogar.grab_focus()


func _on_novo_jogo_pressed() -> void:
	main_node.prepare_game()
	self.queue_free()


func _on_como_jogar_pressed() -> void:
	main_node.how_to_play_screen()
	self.queue_free()


func _on_novo_jogo_focus_entered() -> void:
	$Novo_Jogo_audio.play()


func _on_como_jogar_focus_entered() -> void:
	$Como_Jogar_mini.play()
