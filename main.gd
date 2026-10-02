extends Control

var title_label: Label
var story_label: Label
var input_box: LineEdit
var print_button: Button
var paper_label: Label
var status_label: Label
var hearts: Array[Label] = []
var printed_count := 0

func _ready() -> void:
    _build_ui()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#09090d")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var monitor := ColorRect.new()
    monitor.color = Color("#17151c")
    monitor.position = Vector2(80, 45)
    monitor.size = Vector2(800, 450)
    add_child(monitor)

    title_label = Label.new()
    title_label.text = "PRINT LOVE"
    title_label.position = Vector2(120, 70)
    title_label.add_theme_font_size_override("font_size", 30)
    title_label.add_theme_color_override("font_color", Color("#ffb6d5"))
    add_child(title_label)

    story_label = Label.new()
    story_label.text = "There is a printer connected to this old computer.\nIt only prints messages that mean something."
    story_label.position = Vector2(120, 125)
    story_label.add_theme_font_size_override("font_size", 18)
    story_label.add_theme_color_override("font_color", Color("#e8dce4"))
    add_child(story_label)

    input_box = LineEdit.new()
    input_box.placeholder_text = "Type a message..."
    input_box.position = Vector2(120, 215)
    input_box.size = Vector2(500, 48)
    input_box.add_theme_font_size_override("font_size", 18)
    add_child(input_box)

    print_button = Button.new()
    print_button.text = "PRINT"
    print_button.position = Vector2(640, 215)
    print_button.size = Vector2(130, 48)
    print_button.add_theme_font_size_override("font_size", 18)
    print_button.pressed.connect(_on_print_pressed)
    add_child(print_button)

    status_label = Label.new()
    status_label.text = "PRINTER READY"
    status_label.position = Vector2(120, 285)
    status_label.add_theme_color_override("font_color", Color("#8d8790"))
    add_child(status_label)

    paper_label = Label.new()
    paper_label.text = ""
    paper_label.position = Vector2(120, 330)
    paper_label.size = Vector2(650, 110)
    paper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    paper_label.add_theme_font_size_override("font_size", 22)
    paper_label.add_theme_color_override("font_color", Color("#30262c"))
    paper_label.add_theme_color_override("font_shadow_color", Color("#ffffff"))
    paper_label.add_theme_constant_override("shadow_offset_x", 2)
    paper_label.add_theme_constant_override("shadow_offset_y", 2)
    add_child(paper_label)

func _on_print_pressed() -> void:
    var message := input_box.text.strip_edges()
    if message.is_empty():
        status_label.text = "THE PRINTER IS WAITING..."
        return

    printed_count += 1
    status_label.text = "PRINTING..."
    print_button.disabled = true
    input_box.editable = false

    await get_tree().create_timer(0.7).timeout
    paper_label.text = "────────────────────────\n  " + message + "\n────────────────────────"
    status_label.text = "PRINTED  •  SHEET " + str(printed_count)
    input_box.clear()
    input_box.editable = true
    print_button.disabled = false
    _spawn_heart()

    if printed_count == 3:
        await get_tree().create_timer(0.8).timeout
        story_label.text = "The printer makes a sound you didn't press.\nSomething has started listening."
        status_label.text = "...DID YOU ASK FOR THIS?"

func _spawn_heart() -> void:
    var heart := Label.new()
    heart.text = "♥"
    heart.position = Vector2(720, 360)
    heart.add_theme_font_size_override("font_size", 24)
    heart.add_theme_color_override("font_color", Color("#ff7faf"))
    add_child(heart)
    hearts.append(heart)
    var tween := create_tween()
    tween.set_parallel(true)
    tween.tween_property(heart, "position", heart.position + Vector2(0, -70), 1.0)
    tween.tween_property(heart, "modulate:a", 0.0, 1.0)
    tween.finished.connect(func():
        if is_instance_valid(heart):
            heart.queue_free()
    )
