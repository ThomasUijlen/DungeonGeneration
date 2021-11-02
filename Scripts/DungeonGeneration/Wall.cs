using Godot;
using System;

public class Wall : Spatial
{
    [Export] public int priority = 0;
    public Tile tile;
    public bool needsDeletion = false;

    public TileHandler TileHandler;

    public override void _Ready() {
        TileHandler = (TileHandler)GetNode("/root/TileHandler");
        CallDeferred("registerPlacedWall");
        CallDeferred("checkForDeletion");
    }

    public void checkForDeletion() {
        if(needsDeletion) {
            GetParent().RemoveChild(this);
        }
    }

    public void registerPlacedWall() {
        TileHandler.wallsWaitingForPlacement -= 1;
    }

    public bool checkPlacement(Vector3 translation) {
        if(TileHandler.canOverwriteWall(translation,priority,this)) {
            return true;
        }
        return false;
    }

    public override void _ExitTree() {
        if(TileHandler.wallList.Contains(Translation)) {
            if(TileHandler.wallList[Translation] == this) {
                TileHandler.wallList.Remove(Translation);
            }
        }
    }
}
