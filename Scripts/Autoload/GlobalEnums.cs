using Godot;
using System;

public class GlobalEnums : Node
{
    public enum WALL_SETTINGS {
	NO_WALL,
	WALL,
	WINDOW,
	DOOR,
	RANDOM
};

public enum TILE_STATES {
	CREATED,
	GENERATED,
	FINALIZED
};

public enum TILE_FILL_STATES {
	HOLLOW,
	SOLID
};
}
