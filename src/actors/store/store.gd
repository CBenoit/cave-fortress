extends RigidBody2D

enum {
	GUN,
	MELEE,
	EXPLOSIVE,
	AMMO,
	BlOCK,
	TRAP
}

var category = GUN

# SHOP CONTENT =================
enum {ITEM_ID, PRICE}

var gun = [
	[Weapons.UZI, 30],
	[Weapons.SHOTGUN, 60],
	[Weapons.MACHINE_GUN, 150]
]
var melee = [
	[Weapons.SWORD, 30]
]
var explosive = [
	[Weapons.GRENADE_LAUNCHER,150],
	[Weapons.DYNAMITE, 300],
	[Weapons.BUBBLE_GUN, 800]
]
var ammo = [
	[Weapons.UZI, 1],
	[Weapons.SHOTGUN, 5],
	[Weapons.MACHINE_GUN, 2],
	[Weapons.GRENADE_LAUNCHER,30],
	[Weapons.DYNAMITE, 200],
	[Weapons.BUBBLE_GUN, 80]
]
var block = [
	[SolidTiles.TILE_DIRT,2],
	[SolidTiles.TILE_STONE,10],
	[SolidTiles.TILE_STEEL, 20]
]
var trap = []

var shop = [
	gun,
	melee,
	explosive,
	ammo,
	block,
	trap
]



onready var store_zone = get_node("store_zone")

func _ready():
	store_zone.connect("body_enter",self,"connect_entity")
	store_zone.connect("body_exit",self,"disconnect_entity")

# adding/removng player's ability to trade

func connect_entity(entity):
	entity.connect("use",self,"open_UI")

func disconnect_entity(entity):
	entity.disconnect("use",self,"open_UI")

func open_UI(player):
	pass

# shop management
func add_to_shop(item_category, ID, price):
	var found = false
	for item in shop[item_category]:
		if item[ITEM_ID] == ID:
			found = true

	if not found:
		shop[item_category].append([ID, price])

func change_price(item_category, ID, price):
	for item in shop[item_category]:
		if item[ITEM_ID] == ID:
			item[PRICE] = price

func remove_item(item_category, ID):
	for item in shop[item_category]:
		if item[ITEM_ID] == ID:
			shop[item_category].erase(item)

func find_item(item_category, ID):
	for item in shop[item_category]:
		if item[ITEM_ID] == ID:
			return item
	print("[WARNING] find_item function failure")
# trade functions

func buy_item(player, ID, quantity):
	var price = find_item(category, ID)[PRICE]

	if category in [GUN, MELEE, EXPLOSIVE]:
		player.add_weapon(ID)
	if category == AMMO:
		player.add_ammunition(ID, quantity)
	player.money -= price*quantity

func sell_item(player, ID, quantity):
	var price = find_item(category, ID)[PRICE]

	if category in [GUN, MELEE, EXPLOSIVE]:
		player.remove_weapon(ID)
	if category == AMMO:
		player.remove_ammunition(ID, quantity)
	player.money += price*quantity