class_name Item
extends Resource

@export var item_name : String
@export var max_stack_size : int = 84

#mesh when its visible outside menus
@export var item_mesh : Mesh = null
#sprite for the item
@export var item_sprite : Texture2D = preload("res://Assets/Textures/placeholder texture.png")

#set if item is also a building
@export var is_building : bool = false
@export var building_resource : Resource
