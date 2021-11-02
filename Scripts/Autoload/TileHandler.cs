using Godot;
using System;
using Godot.Collections;
using System.Collections;

public class TileHandler : Node
{

// #Responsible for all communication with tiles. Also keeps track of all loaded tiles.

public const int TILE_WIDTH = 4;
const int CREATE_DISTANCE = 40;
const int GENERATION_DISTANCE = 30;
const int FINALIZE_DISTANCE = 20;

Dictionary loadedTiles = new Dictionary();

public int roomsWaitingForPlacement = 0;
public ArrayList roomsPlaced = new ArrayList();
public int wallsWaitingForPlacement = 0;
public ArrayList doorsPlaced = new ArrayList();
public int hallWaysWaitingForConnection = 0;
public Dictionary wallList = new Dictionary();

Node GlobalPackedScenes;

Node GlobalVariables;
public GenerationHandler GenerationHandler;

public override void _Ready() {
    GlobalPackedScenes = GetNode("/root/GlobalPackedScenes");
    GenerationHandler = (GenerationHandler)GetNode("/root/GenerationHandler");
	GlobalVariables = GetNode("/root/GlobalVariables");
}

public Vector3 translationToCoord(Vector3 translation) {
	return (translation/TILE_WIDTH).Round();
}

public Tile getTile(Vector3 translation) {
	Vector3 coord = translationToCoord(translation);
	if (loadedTiles.Contains(coord)) {
		return (Tile) loadedTiles[coord];
    }
	return null;
}

void createTile(Vector3 coord) {
	Spatial tile = (Spatial)((PackedScene) GlobalPackedScenes.Get("tileScene")).Instance();
	loadedTiles[coord] = tile;
	((Node)GenerationHandler.Get("currentScene")).CallDeferred("add_child",tile);
	tile.Translation = coord*TILE_WIDTH;
}

void generateTiles() {
	Godot.Collections.Array preloadCoords = getCoordsWithinRange(GENERATION_DISTANCE);
	
	foreach(Vector3 coord in preloadCoords) {
		((Node) loadedTiles[coord]).Call("generate",GenerationHandler, this);
    }
	
	Godot.Collections.Array finalizeCoords = getCoordsWithinRange(FINALIZE_DISTANCE);
	foreach(Vector3 coord in finalizeCoords) {
		((Node) loadedTiles[coord]).Call("finalize");
    }
}

void connectDoors() {
	// //GD.Print(wallsWaitingForPlacement);
	// //GD.Print(doorsPlaced.Count);
	if (wallsWaitingForPlacement > 0) {
		return;
    }
	
	foreach(Door door in doorsPlaced) {
		//GD.Print("loop1");
		foreach(Door possibleConnection in doorsPlaced) {
			//GD.Print("loop2");
			if(door != possibleConnection && !door.connectedTo.Contains(possibleConnection) && door.GlobalTransform.origin.DistanceTo(possibleConnection.GlobalTransform.origin) < 10) {
				connectWithHallway(door,possibleConnection);
            }
        }
    }
}

void connectWithHallway(Door a, Door b) {
	//GD.Print("connect!");
	HallWaySettings hallWaySetting = null;
	foreach(HallWaySettings hallWaySettings in (Godot.Collections.Array)GenerationHandler.dungeonPreset.hallways[a.tile.currentBiome]) {
		if (hallWaySettings.isActiveOnTile(a.GlobalTransform.origin) || hallWaySetting == null) {
			hallWaySetting = hallWaySettings;
		}
    }
	
	HallWay hallWay = (HallWay)((PackedScene)GlobalPackedScenes.Get("hallWayScene")).Instance();
	hallWay.hallWayScene = hallWaySetting.hallWayScene;
	hallWay.findPath(a,b,hallWaySetting,this);
	// hallWay.CallDeferred("findPath",a,b,hallWaySetting,this);
}

public void refreshTiles() {
	loadNewTiles();
	generateTiles();
	connectDoors();
}

void loadNewTiles() {
	Godot.Collections.Array coordsInRange = getCoordsWithinRange(CREATE_DISTANCE);
	
	Godot.Collections.Array oldCoords = (Godot.Collections.Array) loadedTiles.Keys;
	Godot.Collections.Array unchangedCoords = new Godot.Collections.Array();
	Godot.Collections.Array newCoords = new Godot.Collections.Array();
	
	foreach(Vector3 coord in coordsInRange) {
		if(loadedTiles.Contains(coord)) {
			unchangedCoords.Add(coord);
		} else {
			newCoords.Add(coord);
		}
		oldCoords.Remove(coord);
	}
	

	foreach(Vector3 coord in oldCoords) {
		((Node)loadedTiles[coord]).CallDeferred("queue_free");
		loadedTiles.Remove(coord);
	}
	
	foreach(Vector3 coord in newCoords) {
		createTile(coord);
	}
}

Godot.Collections.Array getCoordsWithinRange(float loadRange) {
	Vector3 playerCoord = translationToCoord((Vector3)GlobalVariables.Get("playerTranslation"));
	playerCoord.y = 0;
	
	Godot.Collections.Array coords = new Godot.Collections.Array();
	int preloadDistanceHalf = Godot.Mathf.RoundToInt(loadRange/2);
	for(int x = 0; x < loadRange; x++) {
		for(int z = 0; z < loadRange; z++) {
			coords.Add(playerCoord+new Vector3(x-preloadDistanceHalf,0,z-preloadDistanceHalf));
		}
	}
	
	return coords;
}

public bool canOverwriteWall(Vector3 translation,float priority,Wall wall) {
	translation = translation.Round();
	translation = refineCoord(translation);
	
	if(!wallList.Contains(translation)) {
		wallList.Add(translation,wall);
		return true;
	}

	Wall wallToCompare = ((Wall)wallList[translation]);
	if(wallToCompare.priority <= priority) {
		if(wallToCompare.GetParent() != null) {
			wallToCompare.GetParent().CallDeferred("remove_child",wallToCompare);
		} else {
			wallToCompare.needsDeletion = true;
		}
		wallList[translation] = wall;
		return true;
	}else {
		return false;
	}
}

// #This function might look weird, but I ran into a very odd issue and this is the easiest way to solve it.
// #When rounding Vector (-0.001,1,1) it will return (-0,1,1)
// #When rounding Vector (0.001,1,1) it will return (0,1,1)
// #Those two coordinates are EXACTLY the same, but because one 0 is seen as a negative number comparing them will return false
// #This breaks wall placement so this function fixes those issues, couldnt think of a better solution even though this one is quite sloppy :(
public Vector3 refineCoord(Vector3 coord) {
	if(coord.x == -0) {
		coord.x = 0;
		}
	if(coord.y == -0) {
		coord.y = 0;
		}
	if(coord.z == -0) {
		coord.z = 0;
		}
	return coord;
}
}
