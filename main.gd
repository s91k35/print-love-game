extends Control

# PRINT LOVE — an original retro romance mystery game.
# Built as a self-contained Godot 4 project: no external assets required.

const BG := Color("#08080d")
const PANEL := Color("#17151d")
const PANEL_2 := Color("#211d29")
const PINK := Color("#ff9fcf")
const HOT := Color("#e85b9f")
const PALE := Color("#ffeaf5")
const MUTED := Color("#a89ba7")
const PAPER := Color("#fff7ed")
const INK := Color("#332832")
const GREEN := Color("#a8e6cf")
const RED := Color("#ff9b9b")

var screen: Control
var title_label: Label
var scene_label: Label
var body_label: Label
var status_label: Label
var paper_label: Label
var input_box: LineEdit
var main_button: Button
var secondary_button: Button
var choice_a: Button
var choice_b: Button
var choice_c: Button
var character: Control
var progress_label: Label

var state := "intro"
var chapter := 0
var prints := 0
var affection := 0
var trust := 0
var courage := 0
var memories := 0
var typing_score := 0
var final_choice := ""
var mini_round := 0
var selected_memory := -1
var memory_buttons: Array[Button] = []
var memory_values := ["STAR", "MOON", "KEY", "ROSE", "STAR", "MOON", "KEY", "ROSE"]
var revealed := [false, false, false, false, false, false, false, false]
var save_path := "user://print_love_save.json"

func _ready() -> void:
    _build_shell()
    _show_intro()

func _build_shell() -> void:
    screen = self
    var bg := ColorRect.new()
    bg.color = BG
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(bg)

    var frame := Panel.new()
    frame.position = Vector2(36, 24)
    frame.size = Vector2(888, 492)
    var fs := StyleBoxFlat.new()
    fs.bg_color = PANEL
    fs.border_width_left = 2
    fs.border_width_right = 2
    fs.border_width_top = 2
    fs.border_width_bottom = 2
    fs.border_color = Color("#443444")
    fs.corner_radius_top_left = 12
    fs.corner_radius_top_right = 12
    fs.corner_radius_bottom_left = 12
    fs.corner_radius_bottom_right = 12
    frame.add_theme_stylebox_override("panel", fs)
    add_child(frame)

    var top := ColorRect.new()
    top.color = PANEL_2
    top.position = Vector2(38, 26)
    top.size = Vector2(884, 50)
    add_child(top)

    title_label = _label("PRINT LOVE.exe", Vector2(58, 39), 22, PINK)
    scene_label = _label("BOOT SEQUENCE", Vector2(700, 43), 13, MUTED)
    status_label = _label("READY", Vector2(58, 484), 12, MUTED)
    progress_label = _label("", Vector2(700, 484), 12, MUTED)

    body_label = _label("", Vector2(68, 98), 19, PALE)
    body_label.size = Vector2(590, 100)
    body_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    paper_label = _label("", Vector2(82, 330), 17, INK)
    paper_label.size = Vector2(520, 110)
    paper_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART

    input_box = LineEdit.new()
    input_box.position = Vector2(68, 214)
    input_box.size = Vector2(560, 44)
    input_box.add_theme_font_size_override("font_size", 17)
    input_box.placeholder_text = "Type here..."
    input_box.text_submitted.connect(_on_main_submitted)
    add_child(input_box)

    main_button = _button("CONTINUE", Vector2(650, 214), Vector2(210, 44))
    main_button.pressed.connect(_on_main_pressed)
    secondary_button = _button("SAVE", Vector2(650, 268), Vector2(100, 36))
    secondary_button.pressed.connect(_save_game)
    var load := _button("LOAD", Vector2(760, 268), Vector2(100, 36))
    load.pressed.connect(_load_game)

    choice_a = _button("", Vector2(68, 270), Vector2(250, 42))
    choice_b = _button("", Vector2(335, 270), Vector2(250, 42))
    choice_c = _button("", Vector2(602, 270), Vector2(258, 42))
    choice_a.pressed.connect(func(): _choose(0))
    choice_b.pressed.connect(func(): _choose(1))
    choice_c.pressed.connect(func(): _choose(2))

    _make_paper()
    _hide_choices()

func _make_paper() -> void:
    var paper := Panel.new()
    paper.position = Vector2(68, 318)
    paper.size = Vector2(570, 132)
    var ps := StyleBoxFlat.new()
    ps.bg_color = PAPER
    ps.border_width_left = 2
    ps.border_width_right = 2
    ps.border_width_top = 2
    ps.border_width_bottom = 2
    ps.border_color = Color("#cbbbc2")
    ps.corner_radius_top_left = 4
    ps.corner_radius_top_right = 4
    ps.corner_radius_bottom_left = 4
    ps.corner_radius_bottom_right = 4
    paper.add_theme_stylebox_override("panel", ps)
    add_child(paper)
    paper_label.reparent(paper)

func _label(text: String, pos: Vector2, size_px: int, color: Color) -> Label:
    var l := Label.new()
    l.text = text
    l.position = pos
    l.add_theme_font_size_override("font_size", size_px)
    l.add_theme_color_override("font_color", color)
    add_child(l)
    return l

func _button(text: String, pos: Vector2, size: Vector2) -> Button:
    var b := Button.new()
    b.text = text
    b.position = pos
    b.size = size
    b.add_theme_font_size_override("font_size", 15)
    add_child(b)
    return b

func _show_intro() -> void:
    state = "intro"
    chapter = 0
    scene_label.text = "CHAPTER 0 / ARRIVAL"
    body_label.text = "It is 2:13 AM.\n\nAn old computer wakes up by itself. A pink cursor blinks over one program: PRINT LOVE.\n\nYou do not remember installing it."
    input_box.visible = false
    paper_label.text = "PRINT LOVE\n\nA small printer waits below the monitor.\n\n" + "[ PRESS CONTINUE ]"
    main_button.text = "START"
    status_label.text = "NO USER DETECTED"
    progress_label.text = "0%"
    _hide_choices()
    _hide_character()

func _on_main_submitted(_text: String) -> void:
    if state == "print":
        _print_message()
    elif state == "typing":
        _check_typing()

func _on_main_pressed() -> void:
    match state:
        "intro": _start_game()
        "chapter1": _begin_printing()
        "print": _print_message()
        "character": _character_continue()
        "mini_intro": _start_memory_game()
        "typing": _check_typing()
        "final": _show_ending()
        "ending": _show_intro()

func _start_game() -> void:
    chapter = 1
    state = "chapter1"
    scene_label.text = "CHAPTER 1 / THE PRINTER"
    body_label.text = "The program asks a single question:\n\nWHAT WOULD YOU LIKE TO SAY?\n\nThe cursor waits."
    paper_label.text = "PAPER 01\n\nThe first page is completely blank."
    main_button.text = "USE PRINTER"
    status_label.text = "PRINTER ONLINE"
    progress_label.text = "12%"

func _begin_printing() -> void:
    state = "print"
    input_box.visible = true
    input_box.clear()
    input_box.placeholder_text = "Write anything. The printer is listening..."
    main_button.text = "PRINT"
    body_label.text = "Write a message. Your choices change what the program reveals.\n\nTry being honest."
    paper_label.text = "PAPER 01\n\nNothing has been printed yet."
    status_label.text = "INK READY"
    progress_label.text = "18%"

func _print_message() -> void:
    var message := input_box.text.strip_edges()
    if message.is_empty():
        status_label.text = "THE PRINTER IS WAITING"
        return
    prints += 1
    var lower := message.to_lower()
    if lower.contains("love"):
        affection += 2
    if lower.contains("sorry") or lower.contains("trust"):
        trust += 1
    if lower.contains("scared") or lower.contains("afraid"):
        courage -= 1
    if lower.contains("brave") or lower.contains("stay"):
        courage += 1

    paper_label.text = "PAPER %02d\n\n%s" % [prints, message]
    input_box.clear()
    status_label.text = "SHEET %02d PRINTED" % prints
    progress_label.text = "%d%%" % min(20 + prints * 10, 42)

    if prints == 1:
        body_label.text = "The page comes out warm.\n\nUnder your message, someone has typed a reply in tiny letters:\n\n'I thought you forgot.'"
    elif prints == 2:
        body_label.text = "The printer shudders. A second reply appears:\n\n'I'm still here. But I need to know if you are.'"
    elif prints >= 3:
        _begin_character()

func _begin_character() -> void:
    state = "character"
    input_box.visible = false
    main_button.text = "TALK"
    scene_label.text = "CHAPTER 2 / THE GIRL IN THE SCREEN"
    body_label.text = "The monitor brightens.\n\nA girl appears in the glass: short dark hair, a pink sweater, and a tiny star pinned at her collar.\n\nShe looks directly at you."
    paper_label.text = "MIRA\n\n\"I can only stay if you keep the machine on.\""
    status_label.text = "SIGNAL: 41%"
    progress_label.text = "45%"
    _show_character()

func _character_continue() -> void:
    if affection + trust >= 3:
        body_label.text = "Mira smiles.\n\n\"Okay. Then let's remember the good parts first.\"\n\nShe places four symbols on the screen: STAR, MOON, KEY, ROSE."
        paper_label.text = "MEMORY ARCHIVE\n\nFour memories are scrambled. Put each pair together."
    else:
        body_label.text = "Mira looks away.\n\n\"Before I tell you anything, prove you can remember.\"\n\nFour memories are scrambled across the screen."
        paper_label.text = "MEMORY ARCHIVE\n\nMatch the four pairs."
    state = "mini_intro"
    main_button.text = "OPEN MEMORY GAME"
    status_label.text = "MEMORY LOCKED"
    progress_label.text = "50%"

func _start_memory_game() -> void:
    state = "memory"
    main_button.visible = false
    secondary_button.visible = false
    input_box.visible = false
    paper_label.text = "MEMORY GAME\n\nMatch every pair."
    body_label.text = "Mira's memories are scattered.\n\nFind the matching symbols."
    _hide_choices()
    _clear_memory_buttons()
    revealed = [false, false, false, false, false, false, false, false]
    selected_memory = -1
    memory_values.shuffle()
    for i in range(8):
        var col := i % 4
        var row := i / 4
        var b := _button("?", Vector2(95 + col * 130, 220 + row * 75), Vector2(112, 58))
        b.add_theme_font_size_override("font_size", 19)
        b.pressed.connect(func(idx := i): _memory_click(idx))
        memory_buttons.append(b)
    status_label.text = "MATCHES: 0 / 4"
    progress_label.text = "55%"

func _memory_click(i: int) -> void:
    if revealed[i] or (selected_memory == i):
        return
    memory_buttons[i].text = memory_values[i]
    if selected_memory == -1:
        selected_memory = i
        return
    var first := selected_memory
    if memory_values[first] == memory_values[i]:
        revealed[first] = true
        revealed[i] = true
        memories += 1
        memory_buttons[first].disabled = true
        memory_buttons[i].disabled = true
        selected_memory = -1
        status_label.text = "MATCHES: %d / 4" % memories
        if memories == 4:
            await get_tree().create_timer(0.5).timeout
            _after_memory()
    else:
        selected_memory = -2
        await get_tree().create_timer(0.55).timeout
        memory_buttons[first].text = "?"
        memory_buttons[i].text = "?"
        selected_memory = -1

func _after_memory() -> void:
    _clear_memory_buttons()
    main_button.visible = true
    secondary_button.visible = true
    main_button.text = "CONTINUE"
    state = "typing_intro"
    body_label.text = "The memories return in flashes.\n\nMira remembers a promise you made a long time ago.\n\nBut one word is missing."
    paper_label.text = "FRAGMENT\n\n\"If you ever get lost, I will ______ you.\""
    status_label.text = "MEMORY RESTORED"
    progress_label.text = "68%"

func _show_typing() -> void:
    state = "typing"
    input_box.visible = true
    input_box.clear()
    input_box.placeholder_text = "Type the missing word..."
    main_button.text = "ANSWER"
    body_label.text = "Mira waits.\n\nThe missing word is one of the most important things she remembers."
    paper_label.text = "FRAGMENT\n\n\"If you ever get lost, I will ______ you.\""
    status_label.text = "MEMORY INPUT"
    progress_label.text = "72%"

func _check_typing() -> void:
    var answer := input_box.text.strip_edges().to_lower()
    if answer.is_empty():
        return
    input_box.clear()
    typing_score = 1 if answer in ["find", "remember", "help", "wait"] else 0
    if typing_score == 1:
        trust += 2
        body_label.text = "The screen glows pink.\n\nMira: \"Yes. That's what I said. I would find you.\""
        paper_label.text = "MEMORY COMPLETE\n\nA new page appears: YOU ARE NOT TOO LATE."
    else:
        trust -= 1
        body_label.text = "The screen flickers.\n\nMira: \"No... but maybe you can still make a new promise.\""
        paper_label.text = "MEMORY INCOMPLETE\n\nThe old promise fades. A blank page remains."
    state = "choice"
    input_box.visible = false
    _show_choices(["STAY WITH MIRA", "TURN THE MACHINE OFF", "ASK HER TO COME OUT"])
    main_button.text = ""
    main_button.visible = false
    progress_label.text = "78%"

func _choose(index: int) -> void:
    match state:
        "choice":
            if index == 0:
                affection += 2
                courage += 1
                final_choice = "stay"
                body_label.text = "You sit beside the monitor.\n\nMira's expression softens.\n\n\"Then let's finish this together.\""
            elif index == 1:
                courage += 2
                final_choice = "off"
                body_label.text = "Your hand reaches for the power button.\n\nMira doesn't stop you.\n\n\"Maybe goodbye can be kind.\""
            else:
                trust += 2
                final_choice = "out"
                body_label.text = "You ask if she can leave the screen.\n\nMira laughs quietly.\n\n\"I don't know. But I can try.\""
            paper_label.text = "CHOICE RECORDED\n\nThe final page is waiting."
            _hide_choices()
            main_button.visible = true
            main_button.text = "GO TO FINAL PRINT"
            state = "final"
            status_label.text = "FINAL SEQUENCE"
            progress_label.text = "88%"
        "final_choice":
            pass

func _show_ending() -> void:
    state = "ending"
    main_button.visible = false
    secondary_button.visible = false
    _hide_choices()
    var ending := ""
    if final_choice == "stay" and affection + trust >= 5:
        ending = "TOGETHER"
        body_label.text = "TRUE ENDING — STAY\n\nThe printer makes one final sound. Mira's hand appears on the glass, and for a moment your fingertips meet.\n\nThe screen stays on. So do you."
        paper_label.text = "FINAL PRINT\n\nI LOVE YOU\n\nNot because you remembered everything.\nBecause you stayed long enough to remember something new."
    elif final_choice == "out" and trust >= 4:
        ending = "OPEN DOOR"
        body_label.text = "ENDING — THE OPEN DOOR\n\nThe screen cracks into little squares of light. Mira steps through the glow and vanishes into the room.\n\nOn the floor, a warm sheet of paper remains."
        paper_label.text = "FINAL PRINT\n\nTHANK YOU FOR OPENING THE DOOR.\n\n— MIRA"
    else:
        ending = "GOODBYE"
        body_label.text = "ENDING — A KIND GOODBYE\n\nYou turn the machine off. The room becomes quiet.\n\nThe printer still has enough power for one last page."
        paper_label.text = "FINAL PRINT\n\nGOODBYE IS NOT THE OPPOSITE OF LOVE.\n\nSOMETIMES IT IS HOW LOVE LETS GO."
    status_label.text = ending + " / COMPLETE"
    progress_label.text = "100%"
    _save_game()
    await get_tree().create_timer(0.8).timeout
    _add_restart_button()

func _add_restart_button() -> void:
    var restart := _button("PLAY AGAIN", Vector2(650, 214), Vector2(210, 44))
    restart.pressed.connect(_restart)

func _restart() -> void:
    for child in get_children():
        if child is Button and child != secondary_button and child != main_button:
            if child != choice_a and child != choice_b and child != choice_c:
                child.queue_free()
    prints = 0
    affection = 0
    trust = 0
    courage = 0
    memories = 0
    typing_score = 0
    final_choice = ""
    mini_round = 0
    selected_memory = -1
    main_button.visible = true
    secondary_button.visible = true
    _show_intro()

func _show_choices(labels: Array[String]) -> void:
    choice_a.text = labels[0]
    choice_b.text = labels[1]
    choice_c.text = labels[2]
    choice_a.visible = true
    choice_b.visible = true
    choice_c.visible = true

func _hide_choices() -> void:
    choice_a.visible = false
    choice_b.visible = false
    choice_c.visible = false

func _show_character() -> void:
    _hide_character()
    character = Control.new()
    character.position = Vector2(690, 100)
    character.size = Vector2(190, 150)
    add_child(character)
    character.draw.connect(_draw_character)
    character.queue_redraw()

func _draw_character() -> void:
    if character == null:
        return
    character.draw_circle(Vector2(95, 58), 45, Color("#f6d2c9"))
    character.draw_circle(Vector2(95, 55), 49, Color("#2d2631"))
    character.draw_circle(Vector2(95, 62), 42, Color("#f6d2c9"))
    character.draw_colored_polygon(PackedVector2Array([Vector2(42,120), Vector2(148,120), Vector2(170,150), Vector2(20,150)]), Color("#ef9fbc"))
    character.draw_circle(Vector2(78, 61), 4, INK)
    character.draw_circle(Vector2(112, 61), 4, INK)
    character.draw_line(Vector2(82, 82), Vector2(108, 82), HOT, 3)
    character.draw_circle(Vector2(95, 116), 8, PALE)
    character.draw_line(Vector2(95, 108), Vector2(95, 124), HOT, 2)

func _hide_character() -> void:
    if character != null and is_instance_valid(character):
        character.queue_free()
    character = null

func _clear_memory_buttons() -> void:
    for b in memory_buttons:
        if is_instance_valid(b):
            b.queue_free()
    memory_buttons.clear()

func _save_game() -> void:
    var data := {
        "state": state,
        "chapter": chapter,
        "prints": prints,
        "affection": affection,
        "trust": trust,
        "courage": courage,
        "memories": memories,
        "typing_score": typing_score,
        "final_choice": final_choice
    }
    var file := FileAccess.open(save_path, FileAccess.WRITE)
    if file:
        file.store_string(JSON.stringify(data))
        file.close()
        status_label.text = "GAME SAVED"

func _load_game() -> void:
    if not FileAccess.file_exists(save_path):
        status_label.text = "NO SAVE FOUND"
        return
    var file := FileAccess.open(save_path, FileAccess.READ)
    var data = JSON.parse_string(file.get_as_text())
    file.close()
    if typeof(data) != TYPE_DICTIONARY:
        status_label.text = "SAVE CORRUPTED"
        return
    chapter = int(data.get("chapter", 0))
    prints = int(data.get("prints", 0))
    affection = int(data.get("affection", 0))
    trust = int(data.get("trust", 0))
    courage = int(data.get("courage", 0))
    memories = int(data.get("memories", 0))
    typing_score = int(data.get("typing_score", 0))
    final_choice = str(data.get("final_choice", ""))
    status_label.text = "SAVE LOADED"
    # Resume at a sensible checkpoint rather than reconstructing transient UI.
    if final_choice != "":
        state = "ending"
        body_label.text = "Your last ending is saved.\n\nPress PLAY AGAIN to start a new route."
        paper_label.text = "SAVE DATA\n\nChoice: %s\nPrints: %d\nTrust: %d\nAffection: %d" % [final_choice, prints, trust, affection]
        main_button.visible = false
    elif memories >= 4:
        state = "typing_intro"
        body_label.text = "Your memory archive is restored.\n\nContinue to the missing-word test."
        paper_label.text = "CHECKPOINT\n\nMemory pairs complete."
        main_button.visible = true
        main_button.text = "CONTINUE"
    elif prints >= 3:
        _begin_character()
    elif prints > 0:
        _begin_printing()
        status_label.text = "SAVE LOADED — SHEET %02d" % prints
    else:
        _show_intro()

func _process(_delta: float) -> void:
    # Subtle terminal flicker keeps the interface alive without external assets.
    if state != "ending" and body_label != null:
        var pulse := 0.86 + sin(Time.get_ticks_msec() * 0.004) * 0.08
        body_label.modulate.a = pulse
