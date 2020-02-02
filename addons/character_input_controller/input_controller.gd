tool
extends Control

var input_controller_ui = preload("res://addons/character_input_controller/input_controller_ui.tscn")
var ui_instance

signal tracking_movement
signal tracking_camera

export(float) var stick_max_distance_factor = 0.083
export(float) var camera_sensitivity = 0.002
export(float) var camera_acceleration = 0.20
export(float) var camera_inertia = 0.8

func _ready():
	call_deferred("set_anchors_and_margins_preset", Control.PRESET_WIDE)
	
	ui_instance = input_controller_ui.instance()
	add_child(ui_instance)
	
	ui_instance.STICK_MAX_DISTANCE = OS.get_real_window_size().y * stick_max_distance_factor
	ui_instance.CAMERA_SENSITIVITY = camera_sensitivity
	ui_instance.CAMERA_ACCELERATION = camera_acceleration
	ui_instance.CAMERA_INERTIA = camera_inertia
	
	ui_instance.connect("tracking_movement", self, "_tracking_movement")
	ui_instance.connect("tracking_camera", self, "_tracking_camera")

func get_movement_delta() -> Vector2:
	return ui_instance.get_stick_delta()

func get_camera_relative() -> Vector2:
	return ui_instance.get_camera_relative()

func _tracking_movement(is_tracking):
	emit_signal("tracking_movement", is_tracking)

func _tracking_camera(is_tracking):
	emit_signal("tracking_camera", is_tracking)
