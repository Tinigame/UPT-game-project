extends Node

var items : Dictionary = {}

func _ready():
	_load_items_from("res://Resources/items")

	# sanity check
	for name in items.keys():
		var res = items[name]
		if not (res is Item):
			push_error("%s is not an Item! It's a %s" % [name, res])
		else:
			print("Loaded item:", name)


func _load_items_from(path: String):
	var dir = DirAccess.open(path)
	if dir == null:
		push_error("ItemDatabase: directory not found: " + path)
		return

	dir.list_dir_begin()
	var fname = dir.get_next()
	while fname != "":
		if fname.ends_with(".tres") or fname.ends_with(".res"):
			var res_path = path + "/" + fname
			var res = load(res_path)
			if res is Item:
				items[res.item_name] = res
		fname = dir.get_next()
	dir.list_dir_end()


func get_item_resource(item_name: String) -> Item:
	if items.has(item_name):
		return items[item_name]
	push_warning("Resource not found for item: " + item_name)
	return null
