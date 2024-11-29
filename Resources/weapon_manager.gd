extends Resource

class_name WeaponDefaults

signal update_stats

@export_category("Weapon Stats")
@export var Name: String
@export_enum("Pistol","Shotgun") var Type: String
@export_enum("Light","Medium","Heavy") var AmmoType: String
@export var AltFire: bool
@export var AmmoCap: int
@export var LoadedAmmo: int
@export var Damage: int
@export var AmmoIncrement: int
@export_enum("Common:60","Rare:25","Epic:15") var Rarity: int

@export_category("Animations")
@export var Draw: String
@export var Idle: String
@export var Walk: String
@export var Shoot: String
@export var Shoot2: String
@export var Reload: String

@export_category("Visual Presets")
@export var CanShoot: float
@export var CanShoot2: float
@export var DrawTime: float
@export var StartLoading: float
@export var AmmoLoaded: float
