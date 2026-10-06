# Managed by Ansible: system default qtile config for the VDI. A user's own
# ~/.config/qtile/config.py takes over when present.
#
# Mirrors the niri binds on Ted (nixfiles modules/desktop/niri/binds.nix) as far
# as an X11 tiling WM can: niri's scrolling columns map to qtile's Columns layout,
# niri-quake to a ScratchPad drop-down, swaync to dunst, cliphist to CopyQ.
# Left out: overview, monitor power-off, brightness keys (no monitor on a VPS).
import os
import shutil

from libqtile import bar, hook, layout, qtile, widget
from libqtile.config import Click, Drag, DropDown, Group, Key, Screen, ScratchPad
from libqtile.lazy import lazy
from libqtile.scratchpad import ScratchPad as ScratchPadGroup

mod = "mod4"
terminal = "kitty"
volume = "wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@"
workspaces = ["main", "pim", "chat", "scratch", "music"]


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
    Key([mod], "Escape", lazy.spawn("i3lock -c 000000"), desc="Lock the screen"),

    Key([mod], "Return", lazy.spawn(terminal), desc="Terminal"),
    Key([mod], "t", lazy.spawn(terminal), desc="Terminal: kitty"),
    Key([mod], "e", lazy.spawn("thunar"), desc="File manager: thunar"),
    Key([mod], "d", lazy.spawn("rofi -show drun"), desc="Run an application: rofi"),
    Key([mod], "y", lazy.spawn("copyq toggle"), desc="Clipboard history"),
    Key([mod], "period", lazy.spawn("rofi -show emoji -modi emoji"), desc="Emoji picker"),
    Key([mod], "comma", lazy.spawn("rofi -show calc -modi calc -no-show-match -no-sort"), desc="Calculator"),
    Key([mod], "n", lazy.spawn("dunstctl history-pop"), desc="Show the last notification again"),
    Key([mod], "w", lazy.spawn("dunstctl close-all"), desc="Dismiss notifications"),
    Key([], "F12", lazy.group["scratchpad"].dropdown_toggle("quake"), desc="Drop-down terminal"),
    Key([mod, "shift"], "t", lazy.group["scratchpad"].dropdown_toggle("quake"), desc="Drop-down terminal"),

    Key([mod], "Tab", lazy.screen.toggle_group(), desc="Previous workspace"),
    Key([mod, "shift"], "Tab", lazy.group.focus_back(), desc="Last focused window"),
    Key([mod], "o", lazy.spawn("rofi -show window"), desc="Window list (niri: overview)"),
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
    layout.Columns(border_focus="#5e81ac", border_normal="#2e3440", border_width=2,
                   margin=4, insert_position=1, num_columns=4, split=False),
    layout.Max(),
]

floating_layout = layout.Floating(float_rules=[
    *layout.Floating.default_float_rules,
])

mouse = [
    Drag([mod], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([mod], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
    Click([mod], "Button2", lazy.window.bring_to_front()),
]

widget_defaults = dict(font="Noto Sans", fontsize=13, padding=4)
screens = [Screen(top=bar.Bar([
    widget.GroupBox(visible_groups=workspaces, highlight_method="line"),
    widget.CurrentLayout(),
    widget.WindowName(),
    widget.KeyboardLayout(configured_keyboards=["de", "us"]),
    widget.Systray(),
    widget.Clock(format="%a %d.%m. %H:%M"),
], 26))]


@hook.subscribe.startup_once
def autostart():
    # tray apps MATE would start through XDG autostart
    for cmd in (["copyq", "--start-server"],):
        if shutil.which(cmd[0]):
            qtile.spawn(cmd)
    # dunst is D-Bus activated on the first notification


follow_mouse_focus = False
bring_front_click = True
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
wmname = "LG3D"   # some Java apps only draw correctly with this name
