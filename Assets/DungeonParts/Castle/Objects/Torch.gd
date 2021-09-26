extends Spatial

var currentLocation = Vector3.ZERO
var targetLocation = Vector3.ZERO

var currentRange = 0.0
var targetRange = 0.0

var speed = 1.0

func _process(delta):
	if currentLocation.distance_to(targetLocation) < 0.05:
		targetLocation = Vector3(rand_range(-1,1),rand_range(-1,1),rand_range(-1,1))*0.1
		speed = rand_range(1,2)
	
	currentLocation = lerp(currentLocation,targetLocation,delta*5*speed)
	$Light.translation = currentLocation
	
	if Vector2(currentRange,0).distance_to(Vector2(targetRange,0)) < 0.05:
		targetRange = rand_range(13.5,14.5)
	
	currentRange = lerp(currentRange,targetRange,delta*10)
	$Light/OmniLight.omni_range = currentRange

func playerMoved():
	var distanceToPlayer = GlobalVariables.playerTranslation.distance_to(global_transform.origin)
	if distanceToPlayer > 20:
		$Light/OmniLight.shadow_enabled = false
		set_process(true)
	else:
		$Light/OmniLight.shadow_enabled = true
		set_process(false)
	
	if distanceToPlayer > 50:
		$Light/OmniLight.visible = false
		$Particles.visible = false
	else:
		$Light/OmniLight.visible = true
		$Particles.visible = true


func _enter_tree():
	GlobalVariables.addObserver(self)

func _exit_tree():
	GlobalVariables.removeObserver(self)
