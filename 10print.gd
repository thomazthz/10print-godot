extends Node2D

onready var Line = preload("line.gd").Line

var hx = 0
var hy = 0
var vx = 0
var vy = 0
var horizontal = false
var vertical = false
var line_width = 4
var update_time = 0.05
var color = Color(1, 1, 1)

var len = null
var lines = []
var timer = Timer.new()

onready var vp_size = get_viewport().get_rect().size

onready var left_right_checkbtn = get_node("control/button_group/left_right_checkbtn")
onready var right_left_checkbtn = get_node("control/button_group/right_left_checkbtn")
onready var top_down_checkbtn = get_node("control/button_group/top_down_checkbtn")
onready var bottom_up_checkbtn = get_node("control/button_group/bottom_up_checkbtn")

onready var line_width_slider = get_node("control/line_width_slider")
onready var line_width_label = get_node("control/line_width_label")

onready var timer_slider = get_node("control/timer_slider")
onready var timer_label = get_node("control/timer_label")

onready var color_picker = get_node("control/color_picker")

enum DrawMode {LEFT_RIGHT, RIGHT_LEFT, TOP_DOWN, BOTTOM_UP}

var checkbtns = {}

func _ready():
	timer.set_wait_time(update_time)
	timer.connect("timeout", self, "update")
	add_child(timer)

	timer.start()

	left_right_checkbtn.connect("toggled", self, "redraw")
	right_left_checkbtn.connect("toggled", self, "redraw")
	top_down_checkbtn.connect("toggled", self, "redraw")
	bottom_up_checkbtn.connect("toggled", self, "redraw")

	line_width_slider.connect("value_changed", self, "set_line_width")
	timer_slider.connect("value_changed", self, "set_update_time")

	color_picker.connect("color_changed", self, "set_color")

	len = greatest_common_divisor(int(vp_size.x), int(vp_size.y))

	checkbtns = {
		DrawMode.LEFT_RIGHT: left_right_checkbtn,
		DrawMode.RIGHT_LEFT: right_left_checkbtn,
		DrawMode.TOP_DOWN: top_down_checkbtn,
		DrawMode.BOTTOM_UP: bottom_up_checkbtn
	}

func _draw():
	if horizontal:
		if checkbtns[DrawMode.LEFT_RIGHT].is_pressed():
			lines.append(gen_line(hx, hy, color))

		if checkbtns[DrawMode.RIGHT_LEFT].is_pressed():
			lines.append(gen_line(hx, hy, color, true))

		hx += len
		if hx >= vp_size.x:
			hx = 0
			hy += len
		if hy >= vp_size.y:
			horizontal = false

	if vertical:
		if checkbtns[DrawMode.TOP_DOWN].is_pressed():
			lines.append(gen_line(vx, vy, color))

		if checkbtns[DrawMode.BOTTOM_UP].is_pressed():
			lines.append(gen_line(vx, vy, color, true))

		vy += len
		if vy >= vp_size.y:
			vy = 0
			vx += len
		if vx >= vp_size.x:
			vertical = false

	if not horizontal and not vertical:
		timer.stop()

	for line in lines:
		draw_line(line.from, line.to, line.color, line_width)

func gen_line(x, y, color, inverse=false):
	var from
	var to
	if not inverse:
		if randf() < 0.5:
			from = Vector2(x, y)
			to = Vector2(x + len, y + len)
		else:
			from = Vector2(x, y + len)
			to = Vector2(x + len, y)
	else:
		if randf() < 0.5:
			from = Vector2(vp_size.x - x, vp_size.y - y)
			to = Vector2(vp_size.x - (x + len), vp_size.y - (y + len))
		else:
			from = Vector2(vp_size.x - x, vp_size.y - (y + len))
			to = Vector2(vp_size.x - (x + len), vp_size.y - y)

	return Line.new(from, to, color)


func redraw(pressed):
	clear()
	horizontal = (checkbtns[DrawMode.LEFT_RIGHT].is_pressed() or checkbtns[DrawMode.RIGHT_LEFT].is_pressed())
	vertical = (checkbtns[DrawMode.TOP_DOWN].is_pressed() or checkbtns[DrawMode.BOTTOM_UP].is_pressed())
	timer.start()


func clear():
	lines.clear()
	hx = 0
	hy = 0
	vx = 0
	vy = 0


func set_line_width(value):
	line_width = value
	line_width_label.set_text("Line width: " + str(line_width))
	clear()


func set_update_time(value):
	update_time = value
	timer.set_wait_time(update_time)
	timer_label.set_text("Update time: " + str(update_time))
	clear()


func set_color(c):
	color = c
	clear()


func greatest_common_divisor(n, m):
	var gcd = n
	while n % gcd != 0 or m % gcd != 0:
		gcd = gcd - 1
	return gcd

