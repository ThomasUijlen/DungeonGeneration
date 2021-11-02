using Godot;
using Godot.Collections;
using System;
using System.Collections;

public class DungeonLibrary : Node
{

// #Used to design and put together a dungeon preset
// #Allows you to create biomes and assign which rooms and hallways to use

// #Used by the generator to recieve parts and generation contraints/rules

public Godot.Collections.Array biomes = new Godot.Collections.Array();
public Dictionary rooms = new Dictionary();
public Dictionary hallways = new Dictionary();

[Export] PackedScene defaultTile;

GenerationHandler GenerationHandler;

public void prepare(GenerationHandler generationHandler) {
	GenerationHandler = generationHandler;
	collectDungeonParts();
}

void collectDungeonParts() {
	collectBiomes();
	collectRooms();
	collectHallways();
}

void collectBiomes() {
	biomes = GetChildren();
}

void collectRooms() {
	foreach(BiomeSettings biome in biomes) {
		biome.setGenerationHandler(GenerationHandler);
		if (biome.HasNode("Rooms")) {
			rooms[biome] = biome.GetNode("Rooms").GetChildren();

			foreach(ISettings room in (Godot.Collections.Array)rooms[biome]) {
				room.setGenerationHandler(GenerationHandler);
			}
        }
    }
}

void collectHallways() {
	foreach(BiomeSettings biome in biomes) {
		biome.setGenerationHandler(GenerationHandler);
		if (biome.HasNode("Hallways")) {
			hallways[biome] = biome.GetNode("Hallways").GetChildren();

			foreach(ISettings hallWay in (Godot.Collections.Array)hallways[biome]) {
				hallWay.setGenerationHandler(GenerationHandler);
			}
        }
    }
}
}
