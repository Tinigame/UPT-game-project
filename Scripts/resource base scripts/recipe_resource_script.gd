class_name Recipe
extends Resource

# one entry = { "item": Item, "amount": int }
@export var recipe_ingredients : Array[RecipeSlot]

@export var recipe_products : Array[RecipeSlot]

#in seconds
@export var crafting_time : float = 1.0

@export var recipe_name : String = "eldritch belt duplication"
@export var recipe_sprite : Texture2D = preload("res://Assets/Textures/placeholder texture.png")

#recipe tab categories
@export_enum("Ehitised", "Vahepealsed", "Kasutatavad") var recipe_tab: String = "Buildings"

@export_flags("Handcraft", "Assembler", "Chemical reactor") var disallowed_crafters = 0
