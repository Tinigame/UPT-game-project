extends Node

enum direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

enum CrafterFlags {
	HANDCRAFT = 1 << 0,
	ASSEMBLER = 1 << 1,
	CHEMICAL_REACTOR = 1 << 2,
}

const CRAFTER_NAMES = {
	CrafterFlags.HANDCRAFT: "Käsitsi meisterdamine",
	CrafterFlags.ASSEMBLER: "Koostepink",
	CrafterFlags.CHEMICAL_REACTOR: "Keemiline reaktor",
}

func get_disallowed_crafter_name(mask: int) -> String:
	var names: Array[String] = []
	for flag in CRAFTER_NAMES.keys():
		if mask & flag:
			names.append(CRAFTER_NAMES[flag])
	if names.is_empty():
		return "Puuduvad"  # No disallowed crafters
	return ", ".join(names)
