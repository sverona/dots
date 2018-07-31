import XMonad
-- LAYOUTS
import XMonad.Layout.Spacing
import XMonad.Layout.Fullscreen 
import XMonad.Layout.NoBorders
import XMonad.Layout.PerWorkspace
import XMonad.Layout.SimplestFloat
import XMonad.Layout.Tabbed 
import XMonad.Layout.ResizableTile
import XMonad.Layout.ThreeColumns
import XMonad.Layout.OneBig
import XMonad.Layout.Gaps

-- WINDOW RULES
import XMonad.ManageHook

import XMonad.Prompt
import XMonad.Actions.DynamicWorkspaces
import XMonad.Actions.CopyWindow (copy)
-- KEYBOARD & MOUSE CONFIG
import XMonad.Util.EZConfig
import XMonad.Actions.FloatKeys
import Graphics.X11.ExtraTypes.XF86
-- STATUS BAR
import XMonad.Hooks.DynamicLog hiding (xmobar, xmobarPP, xmobarColor, sjanssenPP, byorgeyPP)
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.ManageHelpers
import XMonad.Hooks.SetWMName
import XMonad.Hooks.UrgencyHook
import XMonad.Util.Dmenu
--import XMonad.Hooks.FadeInactive
import XMonad.Hooks.EwmhDesktops hiding (fullscreenEventHook)
import System.IO (hPutStrLn)
--import XMonad.Operations
import qualified XMonad.StackSet as W
import qualified XMonad.Actions.FlexibleResize as FlexibleResize
import XMonad.Util.Run (spawnPipe)
import XMonad.Util.Scratchpad
import XMonad.Util.WorkspaceCompare
import XMonad.Actions.CycleWS            -- nextWS, prevWS
import Data.List            -- clickable workspaces
import System.Process

--------------------------------------------------------------------------------------------------------------------
-- DECLARE WORKSPACES RULES
--------------------------------------------------------------------------------------------------------------------
myLayout = gaps [(U, 28), (L, 212)] $ ( tiledSpace  ||| tiled ||| oneBig ||| fullTile )
    where
        tiled          = spacing 5 $ ResizableTall nmaster delta ratio [] 
        tiledSpace     = spacing 60 $ ResizableTall nmaster delta ratio [] 
        bigMonitor     = spacing 5 $ ThreeColMid nmaster delta ratio 
        oneBig         = spacing 5 $ OneBig (fromRational ratio) (fromRational ratio)
        fullScreen     = noBorders(fullscreenFull Full)
        fullTile       = ResizableTall nmaster delta ratio [] 
        borderlessTile = noBorders(fullTile)
        -- Default number of windows in master pane
        nmaster = 1
        -- Percent of the screen to increment when resizing
        delta     = 5/100
        -- Default proportion of the screen taken up by main pane
        ratio     = toRational (2/(1 + sqrt 5 :: Double)) 


--------------------------------------------------------------------------------------------------------------------
-- WORKSPACE DEFINITIONS
--------------------------------------------------------------------------------------------------------------------
--myWorkspaces = ["\57360", "\57361", "\57362", "\57363", "\57364"]    
myWorkspaces = ["1", "2", "3", "4", "5", "6", "7", "8", "9"]

--------------------------------------------------------------------------------------------------------------------
-- APPLICATION SPECIFIC RULES
--------------------------------------------------------------------------------------------------------------------
myManageHook = composeAll     [ resource =? "dmenu"     --> doFloat
                              , resource =? "skype"     --> doFloat
                              , resource =? "steam"     --> doFloat
                                
                              , title    =? "https://www.pinterest.com - Pinterest • The world’s catalog of ideas - Pentadactyl" --> doFloat

                              , resource =? "plugin-container"     --> doFullFloat

                              , resource =? "ario"      --> doShift (myWorkspaces !! 4)
                              , resource =? "ncmpcpp"   --> doShift (myWorkspaces !! 4)
                              , resource =? "alsamixer" --> doShift (myWorkspaces !! 4)
                              , manageDocks]
newManageHook = myManageHook <+> manageHook defaultConfig 

--------------------------------------------------------------------------------------------------------------------
-- DZEN LOG RULES for workspace names, layout image, current program title
--------------------------------------------------------------------------------------------------------------------

myLogHook h = dynamicLogWithPP (defaultPP
               { ppCurrent         = wrap "%{F{{ n_blue }}}%{+u} " " %{F-}%{-u}"
               , ppVisible         = wrap "%{F{{ n_blue }}} " " %{F-}"
               , ppHidden          = wrap "%{F-} " " %{F-}"
               , ppHiddenNoWindows = wrap "%{F{{ n_black }}} " " %{F-}"
               , ppUrgent          = id
               , ppSep             = ""
               , ppWsSep           = ""
               , ppTitle           = const ""
               , ppLayout          = (\x -> case x of
                                            "Full"                       ->    "\57344"
                                            "Spacing 5 ResizableTall"    ->    "\57346"
                                            "ResizableTall"              ->    "\57346"
                                            "SimplestFloat"              ->    "\57521"
                                            "OneBig"                     ->    "\57658"
                                            _                            ->    "\57349"
                                     ) 
               , ppOrder           = \(ws:l:_:_) -> [ws, l]
               , ppOutput          = hPutStrLn h
               , ppSort            = getSortByIndex
               , ppExtras          = []
               }
            )

--------------------------------------------------------------------------------------------------------------------
-- Spawn pipes and menus on boot, set default settings
--------------------------------------------------------------------------------------------------------------------
-- myXmonadBar = "lemonbar -g 200x18+6+6 -u2 -o-2 {% for fn in term_fonts %}-f '{{ fn }}' {% endfor %}-F '{{ fgc }}' -B '{{ bgc }}'"
myXmonadBar = "while read line; do echo W$line; done > /tmp/panel-fifo_0"

main = do
    lemonbar <- spawnPipe myXmonadBar
    xmonad $ ewmh defaultConfig
        { terminal           = myTerminal
        , borderWidth        = 2
        , normalBorderColor  = color0
        , focusedBorderColor = color2
        , focusFollowsMouse  = False
        , modMask            = myModMask
        , layoutHook         = smartBorders $ myLayout
        , workspaces         = myWorkspaces
        , manageHook         = newManageHook
        , handleEventHook    = fullscreenEventHook <+> docksEventHook
        , startupHook        = setWMName "LG3D"
        , logHook            = myLogHook lemonbar
        }

--------------------------------------------------------------------------------------------------------------------
-- Keyboard options
--------------------------------------------------------------------------------------------------------------------
        `additionalKeys`
        [((myModMask .|. shiftMask    , xK_b), spawn "luakit")
        
        ,((myModMask                  , xK_r), spawn "rofi -show run")

        ,((myModMask .|. shiftMask    , xK_c), kill)

        ,((myModMask .|. shiftMask    , xK_l), sendMessage MirrorShrink)
        ,((myModMask .|. shiftMask    , xK_h), sendMessage MirrorExpand)

        ,((myModMask                  , xK_Print), spawn "scrot -s & mplayer /usr/share/sounds/freedesktop/stereo/screen-capture.oga")
        ,((0                         , xK_Print), spawn "scrot & mplayer /usr/share/sounds/freedesktop/stereo/screen-capture.oga")

        ,((0                         , xF86XK_AudioLowerVolume), spawn "/home/malone/bin/dvol2 -d 5 & mplayer /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga")
        ,((0                         , xF86XK_AudioRaiseVolume), spawn "/home/malone/bin/dvol2 -i 5 & mplayer /usr/share/sounds/freedesktop/stereo/audio-volume-change.oga")

        ,((0                         , xF86XK_AudioMute), spawn "/home/malone/bin/dvol2 -t")

        ,((0                         , xK_F10), spawn "mpc next")
        ,((0                         , xK_F11), spawn "mpc toggle")
        ,((0                         , xK_F12), spawn "mpc prev")
       ]

-- Define constants

myTerminal     = "st"
myModMask      = mod4Mask

color0  = "{{ n_black }}"
color8  = "{{ b_black }}"
color1  = "{{ n_red }}"
color9  = "{{ b_red }}"
color2  = "{{ n_green }}"
color10 = "{{ b_green }}"
color3  = "{{ n_yellow }}"
color11 = "{{ b_yellow }}"
color4  = "{{ n_blue }}"
color12 = "{{ b_blue }}"
color5  = "{{ n_magenta }}"
color13 = "{{ b_magenta }}"
color6  = "{{ n_cyan }}"
color14 = "{{ b_cyan }}"
color7  = "{{ n_white }}"
color15 = "{{ b_white }}"

background = "{{ bgc }}"
foreground = "{{ n_white }}"
