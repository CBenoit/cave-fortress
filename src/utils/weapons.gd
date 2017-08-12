extends Node

enum {
	PISTOL,
	DIRT_GUN,
	UZI,
	SHOTGUN,
	MACHINE_GUN,
	GRENADE_LAUNCHER,
	DYNAMITE,
	BUBBLE_GUN,
	SWORD
}

const MAX_CARRIED = 7

var name_to_id = {
	"pistol":0,
	"dirt gun":1,
	"uzi":2,
	"shotgun":3,
	"machine gun":4,
	"grenade launcher":5,
	"dynamite":6,
	"bubble gun":7,
	"sword":8
}

var id_to_name = {
	0:"pistol",
	1:"dirt gun",
	2:"uzi",
	3:"shotgun",
	4:"machine gun",
	5:"grenade launcher",
	6:"dynamite",
	7:"bubble gun",
	8:"sword"
}

var weapons_scn = [
	preload("res://actors/hero/weapons/basic_weapon.tscn"),
	preload("res://actors/hero/weapons/dirt_gun.tscn"),
	preload("res://actors/hero/weapons/uzi.tscn"),
	preload("res://actors/hero/weapons/shotgun.tscn"),
	preload("res://actors/hero/weapons/machine_gun.tscn"),
	preload("res://actors/hero/weapons/grenade_launcher.tscn"),
	preload("res://actors/hero/weapons/dynamite_arm.tscn"),
	preload("res://actors/hero/weapons/bubble_gun.tscn"),
	preload("res://actors/hero/weapons/sword.tscn")

]
