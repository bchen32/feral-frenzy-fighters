class_name Menu

var _queue = []

func _init(item):
	_queue.append(item)
	self._queue = _queue

func next(item):
	_queue.back().hide()
	_queue.append(item)
	item.show()
	if item != null:
		focus_button(item)

func back():
	if len(_queue) > 1:
		_queue.pop_back().hide()
		_queue.back().show()
		focus_button(_queue.back())
	
func focus_button(item):
	for node in item.get_tree().get_nodes_in_group("TitleButtons"):
		if node.is_visible_in_tree():
			node.grab_focus()
			return 
