using Godot;
using System;

public class RoomContainer : Spatial, ITileContainer
{
    float noise = 0.0f;
    ISettings settings;

    TileHandler TileHandler;

    public override void _Ready()
    {
        TileHandler = (TileHandler)GetNode("/root/TileHandler");
        CallDeferred("registerPlacedRoom");
    }

    public String getType() {
        return "room";
    }

    public float getNoise() {
        return noise;
    }
    public void setNoise(float noise) {
        this.noise = noise;
    }

    public ISettings GetSettings() {
        return settings;
    }
    public void setSettings(ISettings settings) {
        this.settings = settings;
    }

    public void registerPlacedRoom() {
        TileHandler.roomsWaitingForPlacement -= 1;
    }
}
