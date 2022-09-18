extends Panel

export(bool) var inventory_item = true
var item = null

func _ready():
	if randi() % 2 == 0:
		var ItemClass = load("res://Ui/Core.tscn")
		item = ItemClass.instance()
		var rand = randi() % 4
		if rand == 0:
			item.element = 10
		if rand == 1:
			item.element = 3
		if rand == 2:
			item.element = 4
		if rand == 3:
			item.element = 1
		item.size = randi() % 3
		
		add_child(item)

func add_core(element, size):
	item = null
	var ItemClass = load("res://Ui/Core.tscn")
	item = ItemClass.instance()
	item.element = element
	item.size = size
				
	add_child(item)

func pickFromSlot():
	remove_child(item)
	var inventoryNode = find_parent("Inventory")
	inventoryNode.add_child(item)
	item = null

func putIntoSlot(new_item):
	item = new_item
	item.position = Vector2(0,0)
	var inventoryNode = find_parent("Inventory")
	inventoryNode.remove_child(item)
	add_child(item)

class_name SlotClass
