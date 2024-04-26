#!/usr/bin/env bash

dconf load / << EOF
[org/gnome/desktop/wm/keybindings]
close=['<Shift><Alt>q']
maximize=@as []
move-to-workspace-left=['<Primary><Alt>a']
move-to-workspace-right=['<Primary><Alt>d']
show-desktop=@as []
switch-to-workspace-left=['<Shift><Alt>a']
switch-to-workspace-right=['<Shift><Alt>d']
unmaximize=@as []

[org/gnome/mutter/keybindings]
toggle-tiled-left=@as []
toggle-tiled-right=@as []

[org/gnome/settings-daemon/plugins/media-keys]
custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']
next=['<Alt><Super>l']
on-screen-keyboard=['<Super>k']
play=['<Alt><Super>space']
previous=['<Alt><Super>h']

[org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0]
binding='<Super>Return'
command='gnome-terminal -- bash -c "tmux new-session -A -s main"'
name='tmux'
EOF
