#!/bin/zsh

# source X application preferences
xrdb ~/.Xresources 


# add local font paths to xfontsel's registry
xset +fp ~/.fonts
xset +fp /usr/share/fonts/local 
xset fp rehash 


# apply keyboard overrides
if [ -s ~/.Xmodmap ]; then
    xmodmap ~/.Xmodmap
fi
setxkbmap -option ctrl:nocaps
xcape -e 'Control_L=Escape'

# set cursor style  
xsetroot -cursor_name left_ptr

# turn cursor off when it's inactive
unclutter -grab -noevents -root &


# set clipboard to autogen from selection
autocutsel -fork &
autocutsel -selection PRIMARY -fork &


# set timezone
export TZ="America/Chicago"


# tell Qt apps to use GTK style
export QT_STYLE_OVERRIDE="gtk2"


# start window manager and hotkey daemon
export WM="xmonad"

# start miscellaneous background processes
for daemon in mopidy compton dunst; do
    $daemon &
done

sh ~/.fehbg &

exec "$WM" 2> ~/.xsession-errors
