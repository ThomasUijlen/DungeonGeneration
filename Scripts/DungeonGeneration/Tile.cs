using Godot;
using System;

public class Tile : Spatial
{
    public GlobalEnums.TILE_STATES currentState = GlobalEnums.TILE_STATES.CREATED;

    public Vector3 coords = Vector3.Zero;

    public BiomeSettings currentBiome = null;
    public float biomePriority = -1;

    public TileGenerationSettings currentOccupation = null;
    public float occupationPriority = -1;

    public GlobalEnums.TILE_FILL_STATES fillState = GlobalEnums.TILE_FILL_STATES.SOLID;

    GenerationHandler GenerationHandler;
    TileHandler TileHandler;

    public void generate(GenerationHandler generationHandler, TileHandler tileHandler) {
        if(currentState != GlobalEnums.TILE_STATES.CREATED) {
            return;
        }

        GenerationHandler = generationHandler;
        TileHandler = tileHandler;

        currentState = GlobalEnums.TILE_STATES.GENERATED;
        
        generateBiome();
        generateRooms();
    }

    public void finalize() {
        if(currentState != GlobalEnums.TILE_STATES.GENERATED) {
            return;
        }
        
        if(currentOccupation != null) {
            currentState = GlobalEnums.TILE_STATES.FINALIZED;
            currentOccupation.finalize();
        }
    }

    void generateBiome() {
        foreach(BiomeSettings biome in GenerationHandler.dungeonPreset.biomes) {
            if(biome.isActiveOnTile(Translation) || currentBiome == null) {
                overwriteCurrentBiome(biome);
            }
        }
    }

    void overwriteCurrentBiome(BiomeSettings biome) {
        if(biome.priority > biomePriority) {
            biomePriority = biome.priority;
            currentBiome = biome;
        }
    }

    void generateRooms() {
        foreach(RoomSettings roomSettings in (Godot.Collections.Array)GenerationHandler.dungeonPreset.rooms[currentBiome]) {
            if(roomSettings.isActiveOnTile(Translation)) {
                TileHandler.roomsWaitingForPlacement += 1;
                CallDeferred("createRoom",roomSettings,roomSettings.getLastNoiseValue());
                return;
            }
        }
    }

    void createRoom(RoomSettings roomSettings,float noiseValue) {
        RoomContainer room = (RoomContainer) roomSettings.roomScene.Instance();
        room.setSettings(roomSettings);
        room.Translation = Translation;
        room.RotationDegrees = new Vector3(0,90*roomSettings.getRandomNumber(Translation,0,4),0);
        GenerationHandler.currentScene.CallDeferred("add_child",room);
    }

    public bool overwriteOccupation(TileGenerationSettings occupation) {
        if(occupation.priority > occupationPriority) {
            if(currentOccupation != null) {
                currentOccupation.CallDeferred("queue_free");
            }
            
            occupationPriority = occupation.priority;
            currentOccupation = occupation;
            fillState = currentOccupation.fillType;
            return true;
        }
        
        return false;
    }

    public override void _ExitTree() {
        if(currentOccupation != null) {
            currentOccupation.CallDeferred("queue_free");
        }
    }
}
