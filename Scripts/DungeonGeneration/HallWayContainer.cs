using Godot;
using System;

public class HallWayContainer : Spatial, ITileContainer
{
    float noise = 0.0f;
    ISettings settings;

    public override void _Ready()
    {
        
    }

    public String getType() {
        return "hallway";
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
}
