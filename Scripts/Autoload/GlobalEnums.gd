extends Node

#Contains enums used by multiple scripts. Setting it to autoload makes the enums
#accessible by all scripts

enum WALL_SETTINGS {
	NO_WALL,
	WALL,
	WINDOW,
	DOOR,
	RANDOM
}

enum TILE_STATES {
	CREATED,
	GENERATED,
	ACTIVE
}
