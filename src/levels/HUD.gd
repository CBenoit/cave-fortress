extends CanvasLayer

var current_weapon_label

func _ready():
	current_weapon_label = get_node("current_weapon")

func current_weapon_changed(new_weapon):
	current_weapon_label.set_text("Weapon: " + str(new_weapon.name))
