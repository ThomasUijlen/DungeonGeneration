extends Spatial

#Tells the generator which dungeon to generate

func _ready():
	GenerationHandler.generateDungeon(load("res://DungeonLayouts/Dungeon1.tscn").instance(), 100000)
