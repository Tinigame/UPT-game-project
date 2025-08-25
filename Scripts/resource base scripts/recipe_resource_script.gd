class_name Recipe
extends Resource

# one entry = { "item": Item, "amount": int }
@export var recipe_ingredients : Array[Dictionary] = [
	{ "item": preload("res://Resources/items/item_conveyor.tres"), "amount": 1 }
]

@export var recipe_products : Array[Dictionary] = [
	{ "item": preload("res://Resources/items/item_conveyor.tres"), "amount": 2 }
]

#in seconds
@export var crafting_time : float = 1.0

@export var recipe_name : String = "eldritch belt duplication"
@export var recipe_sprite : Texture2D = preload("res://Assets/Textures/placeholder texture.png")

#recipe tab categories
@export_enum("Buildings", "Intermediates", "Consumables") var recipe_tab: String = "Buildings"
