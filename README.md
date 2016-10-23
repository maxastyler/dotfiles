# dotfiles
A collection of dotfiles stored with GNU stow

##Use

To restore some item, use '$stow package' where package is a folder name from this directory.

##Installed packages

Bspwm, sxhkd for wm, with lemonbar as the panel.
rxvt-unicode-patched for terminal
Uses network manager (nmcli, nmtui) for wireless connections.
Mopidy and GMusicProxy for music
Font awesome for lemonbar

##TODO

Add a cpu/memory monitor to lemonbar. Should be easy enough to do with "ps -eo pcpu | grep -vE '0.0|%CPU' and 'grep -E 'Mem(Total|Free)' /proc/meminfo'
