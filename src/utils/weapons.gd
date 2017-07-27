extends Node

enum {
	PISTOL,
	DIRT_GUN,
	UZI,
	SHOTGUN,
	MACHINE_GUN,
	GRENADE_LAUNCHER,
	TIMED_GRENADE_LAUNCHER,
	DYNAMITE,
	BUBBLE_GUN,
	SWORD
}

var name_to_idx = {
	"pistol":0,
	"dirt gun":1,
	"uzi":2,
	"shotgun":3,
	"machine gun":4,
	"grenade launcher":5,
	"timed grenade launcher":6,
	"dynamite":7,
	"bubble gun":8,
	"sword":9
}

var weapons_scn = [
	preload("res://actors/hero/weapons/basic_weapon.tscn"),
	preload("res://actors/hero/weapons/dirt_gun.tscn"),
	preload("res://actors/hero/weapons/uzi.tscn"),
	preload("res://actors/hero/weapons/shotgun.tscn"),
	preload("res://actors/hero/weapons/machine_gun.tscn"),
	preload("res://actors/hero/weapons/grenade_launcher.tscn"),
	preload("res://actors/hero/weapons/timed_grenade_launcher.tscn"),
	preload("res://actors/hero/weapons/dynamite_arm.tscn"),
	preload("res://actors/hero/weapons/bubble_gun.tscn"),
	preload("res://actors/hero/weapons/sword.tscn")

]