extends RigidBody

var moveDirection = Vector3(0,0,0)
export var acceleration = 10
export var damp = 1
export var gravityAcceleration = 1.0

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	$Body/MovementHelper.translation = moveDirection.normalized()*delta*100
	linear_velocity += $Body/MovementHelper.global_transform.origin-global_transform.origin
	
	linear_velocity.x = lerp(linear_velocity.x,0,delta*damp)
	linear_velocity.z = lerp(linear_velocity.z,0,delta*damp)
	
	if grounded():
		linear_velocity.y = 0.0
	else:
		linear_velocity.y -= gravityAcceleration*delta

func grounded():
	return $DownRay.is_colliding()

const CAMERA_ROTATION_SPEED = 0.01
func rotateCamera(amount):
	$Body/Head.rotation.x -= amount.y*CAMERA_ROTATION_SPEED
	$Body.rotation.y -= amount.x*CAMERA_ROTATION_SPEED
	
	if $Body/Head.rotation.x > PI/2:
		$Body/Head.rotation.x = PI/2
	elif $Body/Head.rotation.x < -PI/2:
		$Body/Head.rotation.x = -PI/2

func _input(event):
	if event is InputEventMouseMotion:
		rotateCamera(event.relative)
		return
	
	if event.is_action_pressed("Forward"):
		moveDirection.z -= 1
		return
	if event.is_action_released("Forward"):
		moveDirection.z += 1
		return
	if event.is_action_pressed("Backward"):
		moveDirection.z += 1
		return
	if event.is_action_released("Backward"):
		moveDirection.z -= 1
		return
	
	if event.is_action_pressed("Left"):
		moveDirection.x -= 1
		return
	if event.is_action_released("Left"):
		moveDirection.x += 1
		return
	if event.is_action_pressed("Right"):
		moveDirection.x += 1
		return
	if event.is_action_released("Right"):
		moveDirection.x -= 1
		return
