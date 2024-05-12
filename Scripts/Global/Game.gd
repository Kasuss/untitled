extends Node

##GLOBAL STATS
var last_damage : int

var max_limits = {
	"LightA": 300,
	"MediumA": 240,
	"HeavyA": 200,
}

var equipped = {
	"Item": "",
	"Damage": 0,
	"Ammo Type": "LightA",
	"Max Size": 0,
	"Mag": 0,
	"Reload Speed": 0,
}

##WEAPONS##

var revolver = {
	"Item": "Revolver",
	"Damage": 10,
	"Ammo Type": "LightA",
	"Max Size": 6,
	"Mag": 6,
	"Reload Speed": 1,
}

var pistol = {
	"Item": "Pistol",
	"Damage": 7,
	"Ammo Type": "LightA",
	"Max Size": 12,
	"Mag": 12,
	"Reload Speed": 1,
}

var rifle = {
	"Item": "Rifle",
	"Damage": 3,
	"Ammo Type": "MediumA",
	"Max Size": 30,
	"Mag": 30,
	"Reload Speed": 1.5,
}
