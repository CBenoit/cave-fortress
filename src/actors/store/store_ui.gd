extends Panel

onready var category_button = get_node("VboxContainer/category_button")
onready var button_list = get_node("item_panel/item_list/button_list")
onready var mode_button = get_node("VboxContainer/mode_button")
onready var quantity = get_node("description/quantity")
onready var transaction_button = get_node("description/transaction_button")
onready var price = get_node("description/price")
onready var close_button = get_node("close_button")

onready var player = get_parent()
onready var store = get_node("../../../objects/store")

enum {BUY, SELL}
var mode = BUY
var idx_to_info = []

func _ready():
	category_button.add_item("gun",0)
	category_button.add_item("melee",1)
	category_button.add_item("explosive",2)
	category_button.add_item("ammo",3)
	category_button.add_item("block",4)
	category_button.add_item("trap",5)
	category_button.select(0)

	category_button.connect("item_selected",self,"list_update")
	button_list.connect("button_selected",self,"update_description")
	mode_button.connect("button_selected",self,"mode_change")
	close_button.connect("pressed",self,"queue_free")

	quantity.connect("text_changed",self,"update_price")



func list_update(idx):
	button_list.clear()
	idx_to_id.clear()
	quantity.set_text("0")
	price.set_text("0")

	var id
	if mode == BUY:
		for item in store.shop[idx]:
			id = item[store.ID]
			button_list.add_item(Weapons.id_to_name(id))
			idx_to_info.append([id,item[store.PRICE]])
	else:
		if idx in [store.GUN,store.MELEE,store.EXPLOSIVE]:
			var item_to_display = store.shop[idx]
			var found = false

			for item in item_to_display:
				id = item[store.ID]
				for weapon in player.carried_weapons:
					if id == weapon[player.ID]:
						found = true

				if found:
					idx_to_info.append([id,item[store.PRICE]])
				else:
					item_to_display.erase(item)


func mode_change(new_mode):
	mode = new_mode
	if mode == BUY:
		transaction_button.set_text("sell")
	else:
		transaction_button.set_text("buy")

func update_description(idx):
	quantity.set_text("1")
	var item_price = idx_to_info[idx][store.PRICE]
	if mode == BUY:
		price.set_text(str(item_price))
	else:
		price.set_text(str(item_price*0.4))

func update_price(text):
	# forcing a numeric quantity
	var numeric = ["0","1","2","3","4","5","6","7","8","9"]
	var s = ""
	for letter in text:
		if letter in numeric:
			s += letter
	if s != "":
		quantity.set_text(s)
	else:
		quantity.set_text(0)

	# changing transaction value
	var deal_price = idx_to_info[idx][store.PRICE]*s.to_int()
	if mode == SELL:
		deal_price *= 0.4
	price.set_text(str(deal_price))

	# showing transaction is impossible




