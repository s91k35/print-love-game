extends Control

var title_label: Label
var story_label: Label
var input_box: LineEdit
var print_button: Button
var paper_panel: Panel
var paper_label: Label
var status_label: Label
var clue_label: Label
var ending_button: Button
var printed_count := 0
var secret_words := 0
var game_state := "start"

const PINK := Color("#ff9fcf")
const PAPER := Color("#fff5e9")
const INK := Color("#3a2632")

func _ready() -> void:
    _build_ui()
    _show_intro()

func _build_ui() -> void:
    var bg := ColorRect.new()
    bg.color = Color("#07070b")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var monitor := ColorRect.new()
    monitor.color = Color("#15131a")
    monitor.position = Vector2(55, 30)
    monitor.size = Vector2(850, 480)
    add_child(monitor)

    var top_bar := ColorRect.new()
    top_bar.color = Color("#211d27")
    top_bar.position = Vector2(55, 30)
    top_bar.size = Vector2(850, 42)
    add_child(top_bar)

    title_label = Label.new()
    title_label.text = "PRINT LOVE.exe"
    title_label.position = Vector2(78, 40)
    title_label.add_theme_font_size_override("font_size", 21)
    title_label.add_theme_color_override("font_color", PINK)
    add_child(title_label)

    story_label = Label.new()
    story_label.position = Vector2(90, 95)
    story_label.size = Vector2(760, 90)
    story_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    story_label.add_theme_font_size_override("font_size", 18)
    story_label.add_theme_color_override("font_color", Color("#e8dce4"))
    add_child(story_label)

    input_box = LineEdit.new()
    input_box.placeholder_text = "Type something you want to print..."
    input_box.position = Vector2(90, 195)
    input_box.size = Vector2(540, 48)
    input_box.add_theme_font_size_override("font_size", 17)
    input_box.text_submitted.connect(_on_text_submitted)
    add_child(input_box)

    print_button = Button.new()
    print_button.text = "PRINT"
    print_button.position = Vector2(650, 195)
    print_button.size = Vector2(160, 48)
    print_button.add_theme_font_size_override("font_size", 18)
    print_button.pressed.connect(_on_print_pressed)
    add_child(print_button)

    status_label = Label.new()
    status_label.text = "PRINTER READY"
    status_label.position = Vector2(90, 258)
    status_label.add_theme_color_override("font_color", Color("#8d8790"))
    add_child(status_label)

    clue_label = Label.new()
    clue_label.position = Vector2(90, 282)
    clue_label.size = Vector2(760, 30)
    clue_label.add_theme_font_size_override("font_size", 14)
    clue_label.add_theme_color_override("font_color", Color("#a78396"))
    add_child(clue_label)

    paper_panel = Panel.new()
    paper_panel.position = Vector2(90, 325)
    paper_panel.size = Vector2(720, 145)
    var paper_style := StyleBoxFlat.new()
    paper_style.bg_color = PAPER
    paper_style.border_width_left = 2
    paper_style.border_width_right = 2
    paper_style.border_width_top = 2
    paper_style.border_width_bottom = 2
    paper_style.border_color = Color("#c9b9bf")
    paper_panel.add_theme_stylebox_override("panel", paper_style)
    add_child(paper_panel)

    paper_label = Label.new()
    paper_label.position = Vector2(18, 16)
    paper_label.size = Vector2(684, 112)
    paper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    paper_label.add_theme_font_size_override("font_size", 19)
    paper_label.add_theme_color_override("font_color", INK)
    paper_panel.add_child(paper_label)

    ending_button = Button.new()
    ending_button.text = "OPEN THE LAST PRINT"
    ending_button.position = Vector2(610, 480)
    ending_button.size = Vector2(200, 30)
    ending_button.visible = false
    ending_button.pressed.connect(_show_secret)
    add_child(ending_button)

func _show_intro() -> void:
    story_label.text = "You found an old computer in an empty room.\nThere is one program installed. It is already open.\n\nPRINT LOVE wants to know what you would like to say."
    clue_label.text = "TIP: Some words make the printer behave differently."
    paper_label.text = "The paper tray is empty.\n\nType a message above and press PRINT."

func _on_text_submitted(_text: String) -> void:
    _on_print_pressed()

func _on_print_pressed() -> void:
    var message := input_box.text.strip_edges()
    if message.is_empty():
        status_label.text = "THE PRINTER IS WAITING..."
        return

    printed_count += 1
    var lower := message.to_lower()
    if lower.contains("love") or lower.contains("sorry") or lower.contains("alice"):
        secret_words += 1

    status_label.text = "PRINTING SHEET %02d..." % printed_count
    print_button.disabled = true
    input_box.editable = false

    await get_tree().create_timer(0.45).timeout
    paper_label.text = "PRINT LOVE / SHEET %02d\n\n%s" % [printed_count, message]
    status_label.text = "PRINT COMPLETE"
    input_box.clear()
    input_box.editable = true
    print_button.disabled = false

    _animate_paper()
    _update_story()

func _update_story() -> void:
    if printed_count == 1:
        story_label.text = "The printer works.\nBut you don't remember connecting it.\n\nA tiny light on the computer starts blinking."
        clue_label.text = "SYSTEM: One message received."
    elif printed_count == 2:
        story_label.text = "A second sheet slides out before you touch anything.\n\nIt has your name on it."
        clue_label.text = "SYSTEM: Someone else may be using this printer."
    elif printed_count == 3:
        story_label.text = "The room is quiet. Then the printer starts by itself.\n\nThe screen asks: Do you remember me?"
        clue_label.text = "UNKNOWN USER: ONLINE"
    elif printed_count >= 4:
        story_label.text = "The computer has stopped pretending this is a normal program.\n\nThere is one final sheet waiting inside the printer."
        clue_label.text = "SYSTEM: FINAL MESSAGE AVAILABLE"
        ending_button.visible = true

func _animate_paper() -> void:
    paper_panel.scale = Vector2(1.0, 0.15)
    paper_panel.pivot_offset = Vector2(360, 72)
    var tween := create_tween()
    tween.tween_property(paper_panel, "scale", Vector2.ONE, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _show_secret() -> void:
    game_state = "ending"
    ending_button.visible = false
    input_box.editable = false
    print_button.disabled = true
    story_label.text = "THE FINAL SHEET\n\nYou were never printing a message for someone else.\nThe printer was answering you."
    clue_label.text = "CONNECTION CLOSED"
    paper_label.text = "I LOVE YOU.\n\nThank you for staying.\n\n— someone who remembers"
    status_label.text = "END OF PROTOTYPE"

    var flash := ColorRect.new()
    flash.color = Color(1, 1, 1, 0.0)
    flash.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(flash)
    var tween := create_tween()
    tween.tween_property(flash, "color", Color(1, 1, 1, 0.8), 0.08)
    tween.tween_property(flash, "color", Color(1, 1, 1, 0.0), 0.35)
    tween.finished.connect(func(): flash.queue_free())
