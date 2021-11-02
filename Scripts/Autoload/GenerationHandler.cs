using Godot;
using System;

public class GenerationHandler : Node
{
// #Keeps track of the player and makes sure the dungeon gets generated
// #All generation is done within a thread to prevent lag spickes or stuttering

public DungeonLibrary dungeonPreset;

Thread generationThread;
bool threadActive = false;
Semaphore semaphore = new Semaphore();

public RandomNumberGenerator randomNumberGenerator = new RandomNumberGenerator();
public OpenSimplexNoise noise = new OpenSimplexNoise();
public int generationSeed = 0;

public Node currentScene;

Node GlobalVariables;
TileHandler TileHandler;

override public void _Ready() {
    GlobalVariables = GetNode("/root/GlobalVariables");
    TileHandler = (TileHandler)GetNode("/root/TileHandler");


	GlobalVariables.Call("addObserver",this);
	currentScene = GetTree().CurrentScene;
}

void generateDungeon(DungeonLibrary dungeonToGenerate, int generationSeed) {
	dungeonPreset = dungeonToGenerate;
	dungeonPreset.prepare(this);
	
	this.generationSeed = generationSeed;
	startThread();
	activateThread();
}


// #Thread logic --------------------------------------------------------------------------
void startThread() {
	threadActive = true;
	generationThread = new Thread();
	generationThread.Start(this,"threadFunction","data",Thread.Priority.High);
}

void activateThread() {
	semaphore.Post();
}

public void threadFunction(String data) {
	while(threadActive) {
		semaphore.Wait();
		TileHandler.refreshTiles();
		CallDeferred("checkForThreadRerun");
    }
}

public void checkForThreadRerun() {
	if (TileHandler.roomsWaitingForPlacement > 0 || TileHandler.wallsWaitingForPlacement > 0) {
		semaphore.Post();
    }
}

// #Wait for thread to finish when exiting the application to properly dispose of it
public void _Notification(int what) {
	// if (what == MainLoop.NotificationWmQuitRequest) {
	// 	threadActive = false;
	// 	generationThread.WaitToFinish();
	// }
}

public void playerMoved() {
	activateThread();
}

}
