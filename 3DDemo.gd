extends Spatial

onready var input_controller = $CharacterInputController
onready var camera = $World/Yaw/Pitch/Camera
onready var yaw = 0
onready var pitch = 0

func _physics_process(delta):
	var move_delta = input_controller.get_movement_delta()
	var camera_delta = input_controller.get_camera_relative() * 100
	
	yaw = fmod(yaw - camera_delta.x, 360)
	pitch = clamp(pitch - camera_delta.y, -90, 90)
	
	var camera_forward = -camera.global_transform.basis.z
	var camera_lateral = Vector3.FORWARD.rotated(Vector3(0,1,0), deg2rad(yaw) + PI/2)
	
	$World/Yaw.translation += camera_forward * -move_delta.y * delta * 4
	$World/Yaw.translation += camera_lateral * -move_delta.x * delta * 4

	$World/Yaw.set_rotation(Vector3(0, deg2rad(yaw), 0))
	$World/Yaw/Pitch.set_rotation(Vector3(deg2rad(pitch), 0, 0))
