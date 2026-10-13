extends EnchantScript


func modify_points(score: Dictionary, _card_res: CardResource, _slot: Slot) -> void:
	score["points"] *= 2


func update_visual_position(card: Card, shader_node: Node) -> void:
	var shader_mat: ShaderMaterial = shader_node.material as ShaderMaterial
	if shader_mat:
		shader_mat.set_shader_parameter("card_position", card.global_position)
