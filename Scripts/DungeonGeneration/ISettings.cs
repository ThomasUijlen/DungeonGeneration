using Godot;
using System;

public interface ISettings
{
    bool isActiveOnTile(Vector3 translation);

    float getLastNoiseValue();

    float getNoise(Vector3 translation);

    int getRandomNumber(Vector3 translation, int mi, int ma);

    void setGenerationHandler(GenerationHandler generationHandler);
}
