extends Control

onready var input_controller = $CharacterInputController
onready var character = $Character
onready var shoot_button = $ShootButton

onready var tracking_movement = false

func _ready():
	shoot_button.connect("gui_input", self, "_on_shoot_button_input")
	$CharacterInputController.connect("tracking_movement", self, "_on_tracking_movement")

func _on_shoot_button_input(ev : InputEvent):
	if (ev is InputEventScreenTouch or (ev is InputEventMouseButton and ev.is_pressed())):
		$Shot.show()
		$Shot.rotation_degrees = $Character.rotation_degrees
		$Shot.position = $Character.position

func _on_tracking_movement(is_tracking):
	tracking_movement = is_tracking

func _physics_process(delta):
	if (tracking_movement):
		var move_delta = input_controller.get_movement_delta()
		var camera_delta = input_controller.get_camera_relative() * 100
		
		$Character.position += move_delta * delta * 100
		$Character.rotation_degrees = rad2deg(Vector2.UP.angle_to(move_delta))

	if $Shot.visible:
		$Shot.position += Vector2.UP.rotated($Shot.rotation) * 300 * delta
