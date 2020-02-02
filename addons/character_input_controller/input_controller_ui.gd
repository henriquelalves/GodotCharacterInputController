extends Control

class_name InputUI

var STICK_MAX_DISTANCE = 0
var CAMERA_SENSITIVITY = 0.002
var CAMERA_ACCELERATION = 0.20
var CAMERA_INERTIA = 0.80

onready var is_mobile: bool = false
onready var analog_stick_image: TextureRect = null
onready var movement_stick_anchor: Sprite = $MovementAnalogAnchor
onready var movement_analog_stick: Sprite = movement_stick_anchor.get_child(0)

signal tracking_movement
signal tracking_camera

var _tracking_movement: bool = false
var _movement_touch_id: int = -1

var _tracking_camera: bool = false
var _camera_touch_id: int = -1
var _camera_relative_mov: Vector2 = Vector2.ZERO

func get_stick_delta() -> Vector2:
	if not _tracking_movement:
		return Vector2(0,0)
	var analog_stick_pos = movement_analog_stick.position
	analog_stick_pos /= (STICK_MAX_DISTANCE / movement_stick_anchor.scale.x)
	print(analog_stick_pos)
	return analog_stick_pos

func get_camera_pressed() -> bool:
	return _tracking_camera

func get_camera_relative() -> Vector2:
	return _camera_relative_mov

func _ready():
	var os_name = OS.get_name()
	is_mobile = os_name == "Android" or os_name == "iOS"
	
	var _err
	_err = $MovementInputBlocker.connect("gui_input", self, "_on_movement_gui_input")
	_err = $CameraRotationInputBlocker.connect("gui_input", self, "_on_camera_gui_input")
	analog_stick_image = $AnalogStickExterior

func _process(_delta: float):
	_camera_relative_mov = lerp(_camera_relative_mov, Vector2.ZERO, 1 - CAMERA_INERTIA)
	# Analog Alpha
	var analog_alpha = analog_stick_image.modulate.a
	if _tracking_movement:
		analog_stick_image.modulate.a = lerp(analog_alpha, 0, 0.2)
	else:
		analog_stick_image.modulate.a = lerp(analog_alpha, 1, 0.2)

func _input(event):
	if _is_event_click(event):
		# Tracking release from touch ids
		if event.pressed == false:
			if _tracking_movement and _get_event_index(event) == _movement_touch_id:
				_set_tracking_movement(false)
				movement_stick_anchor.hide()
				movement_analog_stick.position = Vector2.ZERO
			if _tracking_camera and _get_event_index(event) == _camera_touch_id:
				_set_tracking_camera(false)

func _on_movement_gui_input(ev: InputEvent):
	if _is_event_click(ev):
		if ev.pressed:
			if not _tracking_movement:
				_set_tracking_movement(true)
				_movement_touch_id = _get_event_index(ev)
				movement_stick_anchor.position = ev.position
				movement_analog_stick.position = Vector2.ZERO
				movement_stick_anchor.show()
	if _is_event_drag(ev):
		if _get_event_index(ev) == _movement_touch_id:
			var scale = movement_stick_anchor.scale.x
			var mouse_anchor_position = (ev.position - movement_stick_anchor.position)/scale
			mouse_anchor_position = mouse_anchor_position.clamped(STICK_MAX_DISTANCE/scale)
			movement_analog_stick.position = mouse_anchor_position

func _on_camera_gui_input(ev: InputEvent):
	if _is_event_click(ev):
		if ev.pressed:
			if not _tracking_camera:
				_set_tracking_camera(true)
				_camera_touch_id = _get_event_index(ev)
	if _is_event_drag(ev):
		if _get_event_index(ev) == _camera_touch_id and _tracking_camera:
			_camera_relative_mov = ev.relative * pow(ev.relative.length(), CAMERA_ACCELERATION) * CAMERA_SENSITIVITY

func _set_tracking_movement(is_tracking : bool):
	_tracking_movement = is_tracking
	emit_signal("tracking_movement", is_tracking)

func _set_tracking_camera(is_tracking : bool):
	_tracking_camera = is_tracking
	emit_signal("tracking_camera", is_tracking)

func _get_event_index(event : InputEvent):
	if event is InputEventScreenTouch or event is InputEventScreenDrag:
		return event.index
	return 0

func _is_event_click(event : InputEvent):
	return event is InputEventScreenTouch or event is InputEventMouseButton

func _is_event_drag(event : InputEvent):
	return event is InputEventScreenDrag or (event is InputEventMouseMotion)
