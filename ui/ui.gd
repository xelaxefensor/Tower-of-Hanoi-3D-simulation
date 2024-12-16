extends Control

@onready var number_of_disks_line_edit = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/HBoxContainer/LineEdit


func _on_line_edit_text_submitted(new_text: String) -> void:
	if not new_text.is_valid_int():
		number_of_disks_line_edit.text = ""
		number_of_disks_line_edit.placeholder_text = str(Hanoi.number_of_disks)
		return
		
	var new_number_of_disks = new_text.to_int()		
		
	if not new_number_of_disks >= Hanoi.min_number_of_disks:
		number_of_disks_line_edit.text = ""
		number_of_disks_line_edit.placeholder_text = str(Hanoi.number_of_disks)
		return
		
	Hanoi.number_of_disks =  new_text.to_int()


func _on_button_pressed() -> void:
	Hanoi.start_hanoi()
