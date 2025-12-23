extends Area2D



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$CanvasLayer/Novo_jogo/Novo_jogo.grab_focus()
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_novo_jogo_mouse_entered() -> void:
	$CanvasLayer/Novo_jogo/Novo_jogo.grab_focus()


func _on_como_jogar_mouse_entered() -> void:
	$CanvasLayer/Como_jogar/Como_jogar.grab_focus()


func _on_novo_jogo_pressed() -> void:
	var main_node = self.get_parent()
	main_node.prepare_game()
	self.queue_free()
