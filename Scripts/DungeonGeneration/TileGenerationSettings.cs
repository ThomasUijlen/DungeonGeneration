using Godot;
using System;

public class TileGenerationSettings : Spatial
{
    [Export] public GlobalEnums.TILE_FILL_STATES fillType;
    [Export] public PackedScene[] wallTypes;
    [Export] public PackedScene[] windowTypes;
    [Export] public int windowSpawnChance = 100;
    [Export] public PackedScene[] doorTypes;
    [Export] public int doorSpawnChance = 100;

    [Export] public int spawnChance = 100;

    [Export] public bool accessible = true;
    [Export] public float priority = 1;

    [Export] public bool partOfRoom = true;

    public Tile tile;

    bool finalized = false;

    TileHandler TileHandler;

    public override void _Ready() {
        TileHandler = (TileHandler)GetNode("/root/TileHandler");

        ITileContainer Container = (ITileContainer) GetParent();
        if(spawnChance < 100 && Container.GetSettings().getRandomNumber(GlobalTransform.origin*10,0,100) < spawnChance) {
            CallDeferred("queue_free");
            return;
        }
        
        priority += Container.getNoise();
        
        Tile tile = TileHandler.getTile(GlobalTransform.origin);
        if(tile != null) {
            if(tile.overwriteOccupation(this)) {
                this.tile = tile;
                return;
            }
        }
        
        CallDeferred("queue_free");
    }


    public void finalize() {
        if(finalized) {
            return;
        }
        finalized = true;
        placeWall(GetNode<Spatial>("Front"));
        placeWall(GetNode<Spatial>("Back"));
        placeWall(GetNode<Spatial>("Left"));
        placeWall(GetNode<Spatial>("Right"));
    }

    void placeWall(Spatial side) {
        Spatial WallPlacementHelper = GetNode<Spatial>("WallPlacementHelper");
        WallPlacementHelper.Translation = side.Translation*1.1f;
        Tile neighbouringTile = TileHandler.getTile(WallPlacementHelper.GlobalTransform.origin);
        PackedScene wallType = chooseWall(neighbouringTile,side);
        
        if(wallType != null) {
            createWall(side,wallType);
        }
    }

    void createWall(Spatial side, PackedScene wallType) {
        Wall wall = (Wall) wallType.Instance();
        wall.TileHandler = TileHandler;
        if(wall.checkPlacement(side.GlobalTransform.origin)) {
            TileHandler.wallsWaitingForPlacement += 1;
            wall.tile = tile;
            side.CallDeferred("add_child",wall);
        }
    }

    PackedScene chooseWall(Tile neighbouringTile,Spatial side) {
        ITileContainer ownContainer = (ITileContainer)tile.currentOccupation.GetParent();

        if(neighbouringTile.currentOccupation != null && (ownContainer.getType() == "hallway" && ((ITileContainer)neighbouringTile.currentOccupation.GetParent()).getType() == "hallway")) {
            return null;
        }
        if(neighbouringTile.currentOccupation != null && neighbouringTile.currentOccupation.GetParent() == tile.currentOccupation.GetParent()) {
            return null;
        }
        
        
        if(doorTypes.Length > 0) {
            if(ownContainer.GetSettings().getRandomNumber(side.GlobalTransform.origin,0,100) < doorSpawnChance) {
                return doorTypes[ownContainer.GetSettings().getRandomNumber(side.GlobalTransform.origin*10,0,doorTypes.Length-1)];
            }
        }
        
        if(windowTypes.Length > 0 && neighbouringTile.fillState == GlobalEnums.TILE_FILL_STATES.HOLLOW) {
            if(ownContainer.GetSettings().getRandomNumber(side.GlobalTransform.origin,0,100) < windowSpawnChance) {
                return windowTypes[ownContainer.GetSettings().getRandomNumber(side.GlobalTransform.origin*10,0,windowTypes.Length-1)];
            }
        }
        
        return wallTypes[ownContainer.GetSettings().getRandomNumber(side.GlobalTransform.origin*10,0,wallTypes.Length-1)];
    }


}
