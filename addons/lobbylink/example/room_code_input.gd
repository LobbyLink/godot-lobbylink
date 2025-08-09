extends LineEdit

func _on_text_changed(new_text: String):
	var old_caret_column = caret_column
	text = new_text.to_upper()
	caret_column = old_caret_column
	pass 
