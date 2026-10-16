-- Tap and release Left Alt for English, Right Alt for Russian.
o.bind("ALT + Alt_L", "Keyboard layout: English", "hyprctl switchxkblayout all 0", { release = true })
o.bind("ALT + Alt_R", "Keyboard layout: Russian", "hyprctl switchxkblayout all 1", { release = true })
