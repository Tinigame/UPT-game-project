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
	CrafterFlags.HANDCRAFT: "CRAFTER_HANDCRAFT",
	CrafterFlags.ASSEMBLER: "CRAFTER_ASSEMBLER",
	CrafterFlags.CHEMICAL_REACTOR: "CRAFTER_CHEMICAL_REACTOR",
}

func get_disallowed_crafter_name(mask: int) -> String:
	var names: Array[String] = []
	for flag in CRAFTER_NAMES.keys():
		if mask & flag:
			names.append(tr(CRAFTER_NAMES[flag]))
	if names.is_empty():
		return tr("CRAFTER_NOTHING")
	return ", ".join(names)
