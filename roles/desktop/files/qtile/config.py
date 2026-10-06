# Managed by Ansible: system default qtile config for the VDI. A user's own
# ~/.config/qtile/config.py takes over when present.
#
# Mirrors the niri binds on Ted (nixfiles modules/desktop/niri/binds.nix) as far
# as an X11 tiling WM can: niri's scrolling columns map to qtile's Columns layout,
# niri-quake to a ScratchPad drop-down, swaync to dunst, cliphist to CopyQ.
# Left out: overview, monitor power-off, brightness keys (no monitor on a VPS).
#
# Look: Cozytile's floating bar of rounded segments, in Catppuccin Mocha. Rounded
# window corners come from picom; rofi/dunst/kitty themes come from the rice role.
import glob
import os
import random
import shutil

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, DropDown, Group, Key, Screen, ScratchPad
from libqtile.lazy import lazy
from libqtile.scratchpad import ScratchPad as ScratchPadGroup

mod = "mod4"
terminal = "kitty"
volume = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@"
workspaces = ["main", "pim", "chat", "scratch", "music"]

# Catppuccin Mocha
c = dict(base="#1e1e2e", mantle="#181825", crust="#11111b", surface0="#313244",
         surface1="#45475a", overlay0="#6c7086", text="#cdd6f4", subtext0="#a6adc8",
         lavender="#b4befe", blue="#89b4fa", mauve="#cba6f7", pink="#f5c2e7",
         red="#f38ba8", peach="#fab387", green="#a6e3a1", sky="#89dceb")

# Ted's rofi scripts when the rice role installed them, plain rofi otherwise
def rofi(script, fallback):
    path = os.path.expanduser(f"~/.config/rofi/bin/{script}")
    return path if os.access(path, os.X_OK) else fallback

# Wallpapers rotate like awww-random on the FreeBSD box (rotate.conf): a random
# image from this dir every 15 minutes. feh draws them; gdk-pixbuf would load
# them through glycin, which hangs here (see mate-screenshot).
WALLPAPER_DIR = os.path.expanduser("~/.local/share/wallpapers")
WALLPAPER_INTERVAL = 900


@lazy.function
def window_to_adjacent_group(qtile, step):
    """niri move-column-to-workspace-up/down: next/previous group, follow it."""
    groups = [g for g in qtile.groups if not isinstance(g, ScratchPadGroup)]
    i = (groups.index(qtile.current_group) + step) % len(groups)
    if qtile.current_window:
        qtile.current_window.togroup(groups[i].name)
    groups[i].toscreen()


def keys_both(mods, names, cmd, desc=""):
    """German and US keysyms of the same physical key, bound side by side
    (Ted switches de/us; X11 matches the keysym of the active layout)."""
    return [Key(mods, name, cmd, desc=desc) for name in names]


keys = [
    Key([mod, "shift"], "e", lazy.shutdown(), desc="Exit qtile"),
    Key([mod], "q", lazy.window.kill(), desc="Close window"),
    Key([mod], "Escape", lazy.spawn(f"i3lock -c {c['base'][1:]}"), desc="Lock the screen"),

    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "t", lazy.spawn(terminal), desc="Terminal: kitty"),
    Key([mod], "e", lazy.spawn("thunar"), desc="File manager: thunar"),
    Key([mod], "d", lazy.spawn(rofi("launcher", "rofi -show drun")), desc="Run an application: rofi"),
    Key([mod], "y", lazy.spawn(rofi("clipboard", "copyq toggle")), desc="Clipboard history"),
    Key([mod], "period", lazy.spawn(rofi("emoji", "rofi -show emoji -modi emoji")), desc="Emoji picker"),
    Key([mod], "comma", lazy.spawn(rofi("calc", "rofi -show calc -modi calc -no-show-match -no-sort")), desc="Calculator"),
    Key([mod], "n", lazy.spawn("dunstctl history-pop"), desc="Show the last notification again"),
    Key([mod], "w", lazy.spawn("dunstctl close-all"), desc="Dismiss notifications"),
    Key([], "F12", lazy.group["scratchpad"].dropdown_toggle("quake"), desc="Drop-down terminal"),
    Key([mod, "shift"], "t", lazy.group["scratchpad"].dropdown_toggle("quake"), desc="Drop-down terminal"),

    Key([mod], "Tab", lazy.screen.toggle_group(), desc="Previous workspace"),
    Key([mod, "shift"], "Tab", lazy.group.focus_back(), desc="Last focused window"),
    Key([mod], "o", lazy.spawn(rofi("window", "rofi -show window")), desc="Window list (niri: overview)"),
    Key([mod], "space", lazy.widget["keyboardlayout"].next_keyboard(), desc="Switch keyboard layout"),

    Key([mod], "h", lazy.layout.left(), desc="Focus left"),
    Key([mod], "l", lazy.layout.right(), desc="Focus right"),
    Key([mod], "j", lazy.layout.down(), desc="Focus down"),
    Key([mod], "k", lazy.layout.up(), desc="Focus up"),
    Key([mod], "Left", lazy.layout.left()),
    Key([mod], "Right", lazy.layout.right()),
    Key([mod], "Down", lazy.layout.down()),
    Key([mod], "Up", lazy.layout.up()),

    Key([mod, "shift"], "h", lazy.layout.shuffle_left(), desc="Move window left"),
    Key([mod, "shift"], "l", lazy.layout.shuffle_right(), desc="Move window right"),
    Key([mod, "shift"], "j", lazy.layout.shuffle_down(), desc="Move window down"),
    Key([mod, "shift"], "k", lazy.layout.shuffle_up(), desc="Move window up"),
    Key([mod, "shift"], "Left", lazy.layout.shuffle_left()),
    Key([mod, "shift"], "Right", lazy.layout.shuffle_right()),
    Key([mod, "shift"], "Down", lazy.layout.shuffle_down()),
    Key([mod, "shift"], "Up", lazy.layout.shuffle_up()),

    Key([mod, "control"], "h", lazy.layout.swap_column_left(), desc="Swap column left"),
    Key([mod, "control"], "l", lazy.layout.swap_column_right(), desc="Swap column right"),

    Key([mod, "mod1"], "h", lazy.prev_screen(), desc="Focus monitor left"),
    Key([mod, "mod1"], "l", lazy.next_screen(), desc="Focus monitor right"),

    Key([mod], "m", lazy.window.toggle_maximize(), desc="Maximize window"),
    Key([mod], "f", lazy.window.toggle_fullscreen(), desc="Fullscreen"),
    Key([mod, "shift"], "f", lazy.window.toggle_fullscreen(), desc="Fullscreen"),
    Key([mod, "shift"], "space", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod, "mod1"], "f", lazy.window.toggle_floating(), desc="Toggle floating"),
    Key([mod], "c", lazy.window.center(), desc="Center (floating) window"),

    Key([mod], "Page_Down", lazy.screen.next_group(), desc="Next workspace"),
    Key([mod], "Page_Up", lazy.screen.prev_group(), desc="Previous workspace"),
    Key([mod, "shift"], "Page_Down", window_to_adjacent_group(1), desc="Move window to next workspace"),
    Key([mod, "shift"], "Page_Up", window_to_adjacent_group(-1), desc="Move window to previous workspace"),

    *keys_both([mod], ["odiaeresis", "semicolon"], lazy.layout.shuffle_left(), "Move window into left column (ö)"),
    *keys_both([mod], ["adiaeresis", "apostrophe"], lazy.layout.shuffle_right(), "Move window into right column (ä)"),
    *keys_both([mod, "shift"], ["odiaeresis", "semicolon"], lazy.layout.grow_down(), "Window shorter (ö)"),
    *keys_both([mod, "shift"], ["adiaeresis", "apostrophe"], lazy.layout.grow_up(), "Window taller (ä)"),
    *keys_both([mod], ["numbersign", "backslash"], lazy.layout.toggle_split(), "Stack/split column (#)"),
    *keys_both([mod, "shift"], ["numbersign", "backslash"], lazy.window.toggle_maximize(), "Maximize (#)"),
    *keys_both([mod], ["udiaeresis", "bracketleft"], lazy.layout.grow_left(), "Column narrower (ü)"),
    *keys_both([mod], ["plus", "bracketright"], lazy.layout.grow_right(), "Column wider (+)"),
    *keys_both([mod, "shift"], ["udiaeresis", "bracketleft"], lazy.layout.normalize(), "Reset widths (ü)"),
    *keys_both([mod, "shift"], ["plus", "bracketright"], lazy.layout.normalize(), "Reset widths (+)"),
    Key([mod, "shift"], "r", lazy.layout.normalize(), desc="Reset window sizes"),
    Key([mod, "control"], "r", lazy.reload_config(), desc="Reload config"),

    Key([mod, "shift"], "s", lazy.spawn("flameshot gui"), desc="Screenshot area"),
    Key([mod, "mod1"], "s", lazy.spawn("flameshot gui"), desc="Screenshot window"),
    Key([mod, "control"], "s", lazy.spawn("flameshot full -c"), desc="Screenshot screen (clipboard)"),
    Key([], "Print", lazy.spawn("flameshot gui")),
    Key(["shift"], "Print", lazy.spawn("flameshot gui")),
    Key([mod], "Print", lazy.spawn("flameshot full -c")),

    Key([], "XF86AudioRaiseVolume", lazy.spawn(f"{volume} 5%+")),
    Key([], "XF86AudioLowerVolume", lazy.spawn(f"{volume} 5%-")),
    Key([], "XF86AudioMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle")),
    Key([], "XF86AudioMicMute", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle")),
    Key([mod, "shift"], "m", lazy.spawn("wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"), desc="Mute microphone"),
    Key([], "XF86AudioPlay", lazy.spawn("playerctl play-pause")),
    Key([], "XF86AudioStop", lazy.spawn("playerctl stop")),
    Key([], "XF86AudioPrev", lazy.spawn("playerctl previous")),
    Key([], "XF86AudioNext", lazy.spawn("playerctl next")),
]

groups = [Group(name, label=f"{i} {name}") for i, name in enumerate(workspaces, 1)]
for i, name in enumerate(workspaces, 1):
    keys += [
        Key([mod], str(i), lazy.group[name].toscreen(), desc=f"Workspace {name}"),
        Key([mod, "shift"], str(i), lazy.window.togroup(name, switch_group=name != "music"),
            desc=f"Move window to {name}"),
    ]

# niri-quake: a kitty dropping down from the top, hidden again with the same key
groups.append(ScratchPad("scratchpad", [
    DropDown("quake", f"{terminal} --class quake", x=0.15, y=0, width=0.7, height=0.5,
             opacity=0.95, on_focus_lost_hide=False),
]))

# niri's hotkey overlay (Mod+Shift+minus): every described key, searchable in rofi
cheatsheet = os.path.expanduser("~/.cache/qtile-keys.txt")
os.makedirs(os.path.dirname(cheatsheet), exist_ok=True)
with open(cheatsheet, "w") as f:
    for k in keys:
        if k.desc:
            mods = "+".join(m.replace("mod4", "Mod").replace("mod1", "Alt") for m in k.modifiers)
            f.write(f"{mods + '+' if mods else ''}{k.key}\t{k.desc}\n")
keys += keys_both([mod, "shift"], ["minus", "ssharp"],
                  lazy.spawn(f"sh -c 'rofi -dmenu -i -p Keys < {cheatsheet}'"), "Show keybindings")

layouts = [
    # Cozytile: gaps, no X border (picom rounds the corners and dims what lacks focus)
    layout.Columns(border_width=0, margin=9, border_on_single=True, insert_position=1,
                   num_columns=4, split=False),
    layout.Max(border_width=0, margin=9),
]

floating_layout = layout.Floating(float_rules=[
    *layout.Floating.default_float_rules,
])

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

widget_defaults = dict(font="JetBrainsMono Nerd Font Bold", fontsize=13, padding=4,
                       foreground=c["text"], background=c["mantle"])


def pill(*widgets):
    """Cozytile's rounded segment: half-circle glyphs around widgets on surface0."""
    cap = dict(foreground=c["surface0"], background=c["mantle"], padding=0, fontsize=26)
    for w in widgets:
        w.background = c["surface0"]
    return [widget.TextBox("\ue0b6", **cap), *widgets, widget.TextBox("\ue0b4", **cap),
            widget.Spacer(length=8)]


def icon(glyph, color):
    return widget.TextBox(glyph, foreground=color, fontsize=15, padding=6)


screens = [Screen(top=bar.Bar([
    widget.Spacer(length=10),
    *pill(widget.TextBox("\U000f08c7", foreground=c["mauve"], fontsize=18, padding=8,
                         mouse_callbacks={"Button1": lazy.spawn(rofi("powermenu", "true"))})),
    *pill(widget.GroupBox(visible_groups=workspaces, highlight_method="text",
                          active=c["lavender"], inactive=c["overlay0"], this_current_screen_border=c["mauve"],
                          urgent_text=c["red"], disable_drag=True, padding=6, fontsize=14)),
    *pill(widget.CurrentLayout(foreground=c["blue"], padding=8)),
    *pill(icon("\uf002", c["mauve"]),
          widget.TextBox("Search", foreground=c["text"],
                         mouse_callbacks={"Button1": lazy.spawn(rofi("launcher", "rofi -show drun"))})),
    widget.WindowName(foreground=c["subtext0"], max_chars=80, empty_group_string="Desktop", padding=10),
    widget.Systray(padding=6),
    widget.Spacer(length=8),
    *pill(icon("\uf2db", c["peach"]), widget.Memory(format="{MemUsed:.0f}{mm}", update_interval=5)),
    *pill(icon("\U000f057e", c["green"]),
          widget.GenPollCommand(cmd="wpctl get-volume @DEFAULT_AUDIO_SINK@ | awk '{print int($2*100)\"%\" ($3?\" M\":\"\")}'",
                                shell=True, update_interval=2)),
    *pill(widget.KeyboardLayout(configured_keyboards=["de", "us"], foreground=c["sky"], padding=8)),
    *pill(icon("\uf017", c["pink"]), widget.Clock(format="%a %d.%m.  %H:%M")),
    widget.Spacer(length=2),
], 32, margin=[8, 12, 0, 12], background=c["mantle"]))]


def rotate_wallpaper():
    images = [p for p in glob.glob(os.path.join(WALLPAPER_DIR, "**", "*"), recursive=True)
              if p.lower().endswith((".jpg", ".jpeg", ".png", ".webp"))]
    if images and shutil.which("feh"):
        qtile.spawn(["feh", "--no-fehbg", "--bg-fill", random.choice(images)])
    qtile.call_later(WALLPAPER_INTERVAL, rotate_wallpaper)


@hook.subscribe.startup_complete
def start_wallpapers():
    rotate_wallpaper()


@hook.subscribe.startup_once
def autostart():
    # tray apps MATE would start through XDG autostart
    # dunst explicitly: mate-notification-daemon (MATE is installed too) could win
    # the D-Bus activation otherwise
    for cmd in (["copyq", "--start-server"], ["picom", "-b"], ["dunst"]):
        if shutil.which(cmd[0]):
            qtile.spawn(cmd)


follow_mouse_focus = False
bring_front_click = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
wmname = "LG3D"   # some Java apps only draw correctly with this name
