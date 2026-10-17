-- Logical Left Super is on physical Left Alt after the swap: tap it for English.
-- Tap and release Right Alt for Russian.
o.bind("SUPER + Super_L", "Keyboard layout: English", "hyprctl switchxkblayout all 0", { release = true })
o.bind("ALT + Alt_R", "Keyboard layout: Russian", "hyprctl switchxkblayout all 1", { release = true })
