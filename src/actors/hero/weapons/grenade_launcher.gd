extends "./abstract_grenade_weapon.gd"

var contact_grenade = preload("res://actors/bullets/weak_collide_grenade.tscn")
var timed_grenade = preload("res://actors/bullets/weak_timed_grenade.tscn")

enum {CONTACT, TIMED}

var ammo = CONTACT

func _secondary():
	if ammo == CONTACT:
		bullet_scn = timed_grenade
		ammo = TIMED
	else:
		bullet_scn = contact_grenade
		ammo = CONTACT
