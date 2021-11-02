using Godot;
using System;

public class HallWay : Spatial
{
    Vector3 startingCoord;
    Vector3 targetCoord;

    HallWaySettings settings;
    float noise = 0.0f;

    public PackedScene hallWayScene;

    GenerationHandler GenerationHandler;

    public void findPath(Door a, Door b,HallWaySettings settings, TileHandler TileHandler) {
        //GD.Print("path thingy1");
        if ((!IsInstanceValid(a.neighbouringTile) || a.neighbouringTile == null) || (!IsInstanceValid(b.neighbouringTile) || b.neighbouringTile == null)) {
            return;
        }
        
        this.GenerationHandler = TileHandler.GenerationHandler;
        this.settings = settings;
        
        startingCoord = TileHandler.translationToCoord(a.neighbouringTile.GlobalTransform.origin);
        targetCoord = TileHandler.translationToCoord(b.neighbouringTile.GlobalTransform.origin);
        
        float currentX = startingCoord.x;
        float currentZ = startingCoord.z;

        CallDeferred("placeTile",startingCoord,settings);
        CallDeferred("placeTile",targetCoord,settings);
        
        while(currentX != targetCoord.x) {
            if (currentX < targetCoord.x) { currentX += 1;
            }else if (currentX > targetCoord.x) { currentX -= 1;}
            CallDeferred("placeTile",new Vector3(currentX,startingCoord.y,currentZ),settings);
        }
        
        while(currentZ != targetCoord.z) {
            if (currentZ < targetCoord.z) { currentZ += 1;
            }else if (currentZ > targetCoord.z) { currentZ -= 1;}
            CallDeferred("placeTile",new Vector3(currentX,startingCoord.y,currentZ),settings);
        }
        
        a.connectedTo.Add(b);
        b.connectedTo.Add(a);
        a.connectDoor();
        b.connectDoor();
        //GD.Print("path thingy2");
    }

    void placeTile(Vector3 coord,HallWaySettings settings) {
        //GD.Print("palce tile");
        HallWayContainer tile = (HallWayContainer) hallWayScene.Instance();
        tile.setSettings(settings);
        tile.Translation = coord*TileHandler.TILE_WIDTH;
        GenerationHandler.currentScene.CallDeferred("add_child",tile);
        //GD.Print("tile placed");
    }
}
