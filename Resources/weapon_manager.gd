extends Resource

class_name WeaponDefaults

signal update_stats

@export_category("Weapon Stats")
@export var Name: String
@export_enum("Pistol","Shotgun") var WeaponType: String
@export_enum("Light","Medium","Heavy") var AmmoType: String
@export var AmmoCap: int
@export var LoadedAmmo: int
@export var Damage: int
@export var AmmoIncrement: int

@export_category("Animations")
@export var Draw: String
@export var Idle: String
@export var Walk: String
@export var Shoot: String
@export var Shoot2: String
@export var Reload: String

@export_category("Visual Presets")
@export var CanShoot: float
@export var DrawTime: float
@export var StartLoading: float
@export var AmmoLoaded: float
