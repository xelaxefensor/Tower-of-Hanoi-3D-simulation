extends LineEdit


func _on_text_submitted(new_text: String) -> void:
	if not new_text.is_valid_float():
		text = ""
		placeholder_text =  str(new_text)
		return

	if not new_text.to_float() > 0:
		text = ""
		placeholder_text =  str(new_text)
		return

	Settings.mouse_sensitivity = new_text.to_float()
	text = ""
	placeholder_text = str(Settings.mouse_sensitivity)
