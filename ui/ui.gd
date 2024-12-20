extends Control

@onready var number_of_disks_line_edit : LineEdit = $PanelContainer/MarginContainer/VBoxContainer/VBoxContainer/HBoxContainer/Disks/LineEdit


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
	number_of_disks_line_edit.text = ""
	number_of_disks_line_edit.placeholder_text = str(Hanoi.number_of_disks)


func _on_button_pressed() -> void:
	Hanoi.start_hanoi()
