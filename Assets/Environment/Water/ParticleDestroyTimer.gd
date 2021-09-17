extends Timer


func _on_Timer_timeout():
	self.get_parent().queue_free()