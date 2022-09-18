extends Control
var game_rules = load("res://Constants/GameRules.gd").new()

var columns = 5
var x_select = 0
var y_selections = []
var selected_element = 0
var selected_size = 1
var bits = [100, 100, 100, 100, 100]
var half_cores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var cores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
var plus_cores = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

const slotclass = preload("res://Ui/Slot.gd")
onready var inventory_slots = $CraftingUI/GridContainer
var holding_item = null
var item_offset = -35

func _ready ( ):
	$CraftingUI/GridContainer.columns = columns
	var inv_slot_scene = load("res://Ui/InventorySlot.tscn")
	var hot_slot_scene = load("res://Ui/HotbarSlot.tscn")
	for i in range(columns * 4):
		var new_slot = inv_slot_scene.instance()
		$CraftingUI/GridContainer.add_child(new_slot)
	for i in range(columns):
		var new_slot = hot_slot_scene.instance()
		$HBoxContainer.add_child(new_slot)
		y_selections.append(3)
	
	for inv_slot in inventory_slots.get_children():
		inv_slot.connect("gui_input", self, "slot_gui_input", [inv_slot])
	$CraftingUI/CraftingSlot1.connect("gui_input", self, "slot_gui_input", [$CraftingUI/CraftingSlot1])
	$CraftingUI/CraftingSlot2.connect("gui_input", self, "slot_gui_input", [$CraftingUI/CraftingSlot2])
	$CraftingUI/CraftingSlot3.connect("gui_input", self, "slot_gui_input", [$CraftingUI/CraftingSlot3])
	
	update_hotbar()

func slot_gui_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT && event.pressed:
			if holding_item != null:
				if !slot.item: # Place holding item to slot
					slot.putIntoSlot(holding_item)
					holding_item = null
				else: # Swap holding item with item in slot
					var temp_item = slot.item
					slot.pickFromSlot()
					temp_item.global_position = event.global_position + Vector2(item_offset, item_offset)
					slot.putIntoSlot(holding_item)
					holding_item = temp_item
				update_hotbar()
			elif slot.item:
				holding_item = slot.item
				slot.pickFromSlot()
				holding_item.global_position = get_global_mouse_position() + Vector2(item_offset, item_offset)
				update_hotbar()
		if event.button_index == BUTTON_RIGHT && event.pressed:
			if holding_item == null:
				var crafting_slot = null
				if not $CraftingUI/CraftingSlot1.item:
					crafting_slot = $CraftingUI/CraftingSlot1
				elif not $CraftingUI/CraftingSlot2.item:
					crafting_slot = $CraftingUI/CraftingSlot2
				
				if slot.item:
					if slot == $CraftingUI/CraftingSlot1 or slot == $CraftingUI/CraftingSlot2 or slot == $CraftingUI/CraftingSlot3:
						holding_item = slot.item
						slot.pickFromSlot()
						add_core(holding_item.element, holding_item.size)
						holding_item.queue_free()
						holding_item = null
					elif crafting_slot:
						holding_item = slot.item
						slot.pickFromSlot()
						holding_item.global_position = get_global_mouse_position() + Vector2(item_offset, item_offset)
						crafting_slot.putIntoSlot(holding_item)
						holding_item = null
					
					update_hotbar()

func _input(event):
	if holding_item:
		holding_item.global_position = get_global_mouse_position() + Vector2(item_offset, item_offset)
	for i in range(columns):
		if event.is_action_pressed(str(i)):
			if x_select == i:
				y_selections[i] += 1
				if y_selections[i] > 3:
					y_selections[i] = 0
			else:
				x_select = i
			update_hotbar()

func add_core(element, size):
	var succes = false
	for slot in inventory_slots.get_children():
		if not slot.item:
			slot.add_core(element, size)
			succes = true
			break
	return succes

func update_hotbar():
	for slot in $HBoxContainer.get_children():
		if slot.get_child(0):
			slot.get_child(0).queue_free()
	for i in range(columns):
		var slot
		for o in range(4):
			slot = inventory_slots.get_children()[i + columns * y_selections[i]]
			if slot.item and slot.item.size > 0:
				var core_scene = load("res://Ui/Core.tscn")
				var new_core = core_scene.instance()
				new_core.element = slot.item.element
				new_core.size = slot.item.size
				selected_element = slot.item.element
				selected_size = slot.item.size
				$HBoxContainer.get_children()[i].add_child(new_core)
				break
			else:
				y_selections[i] += 1
				if y_selections[i] > 3:
					y_selections[i] = 0
	var selected_slot = $HBoxContainer.get_children()[x_select]
	if selected_slot.get_child(0):
		selected_element = selected_slot.get_child(0).element

func update_bits():
	$Label.text = "Air: " + str(bits[1]) + "   Ice: " + str(bits[2]) + "   Earth: " + str(bits[3]) + "   Fire: " + str(bits[4]) + ""
	var ind = 1
	for button in $CraftingUI/Buttons.get_children():
		if bits[ind] >= 5:
			button.disabled = false
		else:
			button.disabled = true
		ind += 1

func _on_NewCore1_pressed():
	add_core(1, 0)
	half_cores[1] += 1
func _on_NewCore2_pressed():
	add_core(2, 0)
	half_cores[2] += 1
func _on_NewCore3_pressed():
	add_core(3, 0)
	half_cores[3] += 1
func _on_NewCore4_pressed():
	add_core(4, 0)
	half_cores[4] += 1

func _on_CraftButton_pressed():
	if $CraftingUI/CraftingSlot1.item and $CraftingUI/CraftingSlot2.item and not $CraftingUI/CraftingSlot3.item:
		var item1 = $CraftingUI/CraftingSlot1.item
		var item2 = $CraftingUI/CraftingSlot2.item
		var core_scene = load("res://Ui/Core.tscn")
		var new_core = core_scene.instance()
		var succes = false
		if item1.element == item2.element:
			if item1.size == 0 and item2.size == 0:
				succes = true
				new_core.size = 1
			elif item1.size == 1 and item2.size == 1:
				succes = true
				new_core.size = 2
			new_core.element = item1.element
			if succes:
				item1.queue_free()
				item2.queue_free()
		elif item1.size != 2 and item2.size != 2:
				if item1.element < 5 and item2.element < 5:
					succes = true
					new_core.element = game_rules.combining[item1.element][item2.element]
					if item1.size == 1:
						item1.size = 0
						item1.update_texture()
					else:
						item1.queue_free()
					if item2.size == 1:
						item2.size = 0
						item2.update_texture()
					else:
						item2.queue_free()
		if succes:
			$CraftingUI/CraftingSlot3.putIntoSlot(new_core)
