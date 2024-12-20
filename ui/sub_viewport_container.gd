extends SubViewportContainer

var MouseOver : bool = false
signal mouse_clicked

func _on_mouse_entered() -> void:
	#Mouse is out
	MouseOver = true


func _on_mouse_exited() -> void:
	#Mouse is in
	MouseOver = false


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if MouseOver == true:
			mouse_clicked.emit()
