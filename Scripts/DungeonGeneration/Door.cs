using Godot;
using System;
using System.Collections;

public class Door : Wall
{
    public Tile neighbouringTile = null;
    public ArrayList connectedTo = new ArrayList();

    TileHandler TileHandler;

    public override void _Ready() {
        TileHandler = (TileHandler)GetNode("/root/TileHandler");
	    CallDeferred("registerPlacedDoor");
        CallDeferred("registerPlacedWall");
        CallDeferred("checkForDeletion");
    }

    public void registerPlacedDoor() {
        if(hasFreeSpace()) {
            TileHandler.doorsPlaced.Add(this);
        }
    }



    public bool hasFreeSpace() {
        Spatial neighbourPositionHelper = new Spatial();
        AddChild(neighbourPositionHelper);
        neighbourPositionHelper.Translation += new Vector3(0,0,TileHandler.TILE_WIDTH*0.8f);
        
        neighbouringTile = TileHandler.getTile(neighbourPositionHelper.GlobalTransform.origin);
        neighbourPositionHelper.CallDeferred("queue_free");
        
        if(neighbouringTile != null && !IsInstanceValid(neighbouringTile)) {
            return false;
        }
        
        if(neighbouringTile.currentOccupation != null && neighbouringTile.currentOccupation != null && neighbouringTile.currentOccupation.accessible) {
            connectDoor();
        }
        
        return neighbouringTile.currentOccupation == null || !neighbouringTile.currentOccupation.accessible;
    }

    public override void _ExitTree() {
        if(TileHandler.doorsPlaced.Contains(this)) {
            TileHandler.doorsPlaced.Remove(this);
        }
    }

    public void connectDoor() {
        if(HasNode("Arch_Door")) {
            RemoveChild(GetNode("Arch_Door"));
        }
    }
}
