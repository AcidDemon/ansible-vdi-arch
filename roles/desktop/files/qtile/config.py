# Managed by Ansible: system default qtile config for the VDI. A user's own
# ~/.config/qtile/config.py takes over when present.
#
# Bar, layouts and look: Cozytile by Darkkal44 (Rices/Qtile/Cozytile), unchanged
# except its colours, moved to the nearest Catppuccin Mocha shade:
#   #282738 -> base #1e1e2e, #353446 -> surface0 #313244, #CAA9E0 -> mauve #cba6f7,
#   #91B1F0 -> blue #89b4fa, #4B427E -> overlay0 #6c7086, icon pinks -> pink #f5c2e7
# (the PNG assets were recoloured the same way). pywal is not used.
# Keys: the niri binds on Ted (nixfiles modules/desktop/niri/binds.nix).
# Window outline: niri's border (2px, mauve -> blue gradient, inactive surface0);
# X11 can't draw a gradient, so it is two 1px rings, mauve outside, blue inside.
import glob
import os
import random
import shutil

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, DropDown, Group, Key, Match, Screen, ScratchPad
from libqtile.lazy import lazy
from libqtile.scratchpad import ScratchPad as ScratchPadGroup

mod = "mod4"
terminal = "kitty"
volume = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@"
workspaces = ["main", "pim", "chat", "scratch", "music"]
ASSETS = os.path.join(os.path.dirname(os.path.realpath(__file__)), "Assets")


def rofi(script, fallback):
    """Ted's rofi scripts when the rice role installed them, plain rofi otherwise."""
    path = os.path.expanduser(f"~/.config/rofi/bin/{script}")
    return path if os.access(path, os.X_OK) else fallback


# Wallpapers rotate like awww-random on the FreeBSD box (rotate.conf): a random
# image from this dir every 15 minutes, drawn by feh (gdk-pixbuf would go through
# glycin, which hangs here). Stands in for Cozytile's `wal -i`.
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
    Key([mod], "Escape", lazy.spawn("i3lock -c 1e1e2e"), desc="Lock the screen"),

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

# Cozytile shows each workspace as a dot; the names stay for the niri keys
groups = [Group(name, label="\uea71") for name in workspaces]
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

# L A Y O U T S  (Cozytile; Columns first so the niri column keys apply)
lay_config = {
    "border_width": 2,
    "margin": 9,
    "border_focus": ["#cba6f7", "#89b4fa"],
    "border_normal": "#313244",
    "font": "FiraCode Nerd Font",
    "grow_amount": 2,
}

layouts = [
    # split=False draws the *_stack colours, which default to dark red
    layout.Columns(**lay_config, border_on_single=True, num_columns=2, split=False,
                   border_focus_stack=lay_config["border_focus"],
                   border_normal_stack=lay_config["border_normal"]),
    layout.Bsp(**lay_config, fair=False, border_on_single=True),
    layout.Floating(**lay_config),
    layout.Max(**lay_config),
]

widget_defaults = dict(
    font="sans",
    fontsize=12,
    padding=3,
)
extension_defaults = [widget_defaults.copy()]


def search():
    qtile.spawn(rofi("launcher", "rofi -show drun"))


def power():
    qtile.spawn(rofi("powermenu", "true"))


# █▄▄ ▄▀█ █▀█
# █▄█ █▀█ █▀▄

screens = [
    Screen(
        top=bar.Bar(
            [
                widget.Spacer(
                    length=15,
                    background="#1e1e2e",
                ),
                widget.Image(
                    filename=f"{ASSETS}/launch_Icon.png",
                    margin=2,
                    background="#1e1e2e",
                    mouse_callbacks={"Button1": power},
                ),
                widget.Image(
                    filename=f"{ASSETS}/6.png",
                ),
                widget.GroupBox(
                    font="JetBrainsMono Nerd Font",
                    fontsize=24,
                    borderwidth=3,
                    highlight_method="block",
                    active="#cba6f7",
                    block_highlight_text_color="#89b4fa",
                    highlight_color="#313244",
                    inactive="#1e1e2e",
                    foreground="#6c7086",
                    background="#313244",
                    this_current_screen_border="#313244",
                    this_screen_border="#313244",
                    other_current_screen_border="#313244",
                    other_screen_border="#313244",
                    urgent_border="#313244",
                    rounded=True,
                    disable_drag=True,
                    visible_groups=workspaces,
                ),
                widget.Spacer(
                    length=8,
                    background="#313244",
                ),
                widget.Image(
                    filename=f"{ASSETS}/1.png",
                ),
                widget.CurrentLayout(
                    mode="icon",
                    custom_icon_paths=[f"{ASSETS}/layout"],
                    background="#313244",
                    scale=0.50,
                ),
                widget.Image(
                    filename=f"{ASSETS}/5.png",
                ),
                widget.TextBox(
                    text="\uf002 ",
                    font="Font Awesome 7 Free Solid",
                    fontsize=13,
                    background="#1e1e2e",
                    foreground="#cba6f7",
                    mouse_callbacks={"Button1": search},
                ),
                widget.TextBox(
                    fmt="Search",
                    background="#1e1e2e",
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    foreground="#cba6f7",
                    mouse_callbacks={"Button1": search},
                ),
                widget.Image(
                    filename=f"{ASSETS}/4.png",
                ),
                widget.WindowName(
                    background="#313244",
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    empty_group_string="Desktop",
                    max_chars=130,
                    foreground="#cba6f7",
                ),
                widget.Image(
                    filename=f"{ASSETS}/3.png",
                ),
                widget.Systray(
                    background="#1e1e2e",
                    fontsize=2,
                ),
                widget.TextBox(
                    text=" ",
                    background="#1e1e2e",
                ),
                widget.Image(
                    filename=f"{ASSETS}/6.png",
                    background="#313244",
                ),
                widget.TextBox(
                    text="\uf1fe",
                    font="Font Awesome 7 Free Solid",
                    fontsize=13,
                    background="#313244",
                    foreground="#cba6f7",
                ),
                widget.Memory(
                    background="#313244",
                    format="{MemUsed: .0f}{mm}",
                    foreground="#cba6f7",
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    update_interval=5,
                ),
                # Cozytile's battery segment dropped: a VPS has no battery
                widget.Image(
                    filename=f"{ASSETS}/2.png",
                ),
                widget.Spacer(
                    length=8,
                    background="#313244",
                ),
                widget.TextBox(
                    text="\uf027 ",
                    font="Font Awesome 7 Free Solid",
                    fontsize=13,
                    background="#313244",
                    foreground="#cba6f7",
                ),
                widget.Volume(
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                    background="#313244",
                    foreground="#cba6f7",
                    mute_command="pamixer --toggle-mute",
                    volume_up_command="pamixer -i 5",
                    volume_down_command="pamixer -d 5",
                    get_volume_command="pamixer --get-volume-human",
                    update_interval=0.2,
                    unmute_format="{volume}%",
                    mute_format="M",
                ),
                widget.Image(
                    filename=f"{ASSETS}/5.png",
                    background="#313244",
                ),
                widget.TextBox(
                    text="\uf017 ",
                    font="Font Awesome 7 Free Solid",
                    fontsize=13,
                    background="#1e1e2e",
                    foreground="#cba6f7",
                ),
                widget.Clock(
                    format="%I:%M %p",
                    background="#1e1e2e",
                    foreground="#cba6f7",
                    font="JetBrainsMono Nerd Font Bold",
                    fontsize=13,
                ),
                widget.Spacer(
                    length=18,
                    background="#1e1e2e",
                ),
            ],
            30,
            border_color="#1e1e2e",
            border_width=[0, 0, 0, 0],
            margin=[15, 9, 6, 9],   # top, right, bottom, left; 9 = window gap, so the bar lines up with the windows
        ),
    ),
]

# Drag floating layouts.
mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

dgroups_key_binder = None
dgroups_app_rules = []  # type: list
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
floating_layout = layout.Floating(
    border_focus="#181825",
    border_normal="#181825",
    border_width=0,
    float_rules=[
        *layout.Floating.default_float_rules,
        Match(wm_class="confirmreset"),  # gitk
        Match(wm_class="makebranch"),  # gitk
        Match(wm_class="maketag"),  # gitk
        Match(wm_class="ssh-askpass"),  # ssh-askpass
        Match(title="branchdialog"),  # gitk
        Match(title="pinentry"),  # GPG key password entry
    ],
)


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
    # Cozytile's autostart_once.sh starts wal + picom; here picom, dunst (explicitly,
    # so MATE's notification daemon can't take the bus) and CopyQ for the clipboard
    for cmd in (["picom", "-b"], ["dunst"], ["copyq", "--start-server"]):
        if shutil.which(cmd[0]):
            qtile.spawn(cmd)


auto_fullscreen = True
focus_on_window_activation = "smart"
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wmname = "LG3D"
