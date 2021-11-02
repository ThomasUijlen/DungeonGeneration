using Godot;
using System;

public interface ITileContainer
{
    String getType();

    float getNoise();
    void setNoise(float noise);

    ISettings GetSettings();
    void setSettings(ISettings settings);
}
