extends Resource

class_name Pickups

signal update_stats

@export_category("Pickup Stats")
@export var Name: String
@export_enum("Ammo","Attachment","Buff") var Type: String
@export_enum("Common:60",("Rare:25"),"Epic:15") var Rarity: int

@export_subgroup("Ammo Info")
@export var BoxColor: Color
@export var AmmoScene: PackedScene

@export_subgroup("Attachment Info")
@export var ForWeapon: Resource
@export var AttachmentStatBuff: float
@export var AttachmentUnique: Script

@export_subgroup("Buff Info")
@export_enum("Mobility", "Defensive", "Power") var BuffType: String
@export var StatIncrease: float
