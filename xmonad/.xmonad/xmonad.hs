import XMonad
import System.Exit
import XMonad.Actions.Promote
import XMonad.Hooks.DynamicLog
import XMonad.Hooks.ManageDocks
import XMonad.Hooks.FadeInactive
import XMonad.Hooks.SetWMName
import XMonad.Hooks.EwmhDesktops
import XMonad.Prompt.ConfirmPrompt
import XMonad.Layout.ResizableTile
import XMonad.Layout.Spacing
import XMonad.Layout.Gaps
import XMonad.Layout.Spiral
import XMonad.Layout.ThreeColumns
import XMonad.Layout.Fullscreen
import XMonad.Util.CustomKeys -- Use custom keybindings
import XMonad.Util.Run(spawnPipe)
import XMonad.Util.Scratchpad
import XMonad.Util.NamedScratchpad
import Graphics.X11.ExtraTypes.XF86
import Data.Default
import Data.Monoid
import System.IO

import qualified XMonad.StackSet as W
import qualified Data.Map as M

myTerminal :: [Char]
myBorderWidth :: Dimension
myNormalBorderColor :: [Char]
myFocusedBorderColor :: [Char]
myXmobarHlColor :: [Char]
myXmobarTitleColor :: [Char]
myFocusFollowsMouse :: Bool
myModMask :: KeyMask
myTerminal = "urxvt"
myBorderWidth = 4
myNormalBorderColor = "#4c5356"
myFocusedBorderColor = "#607a86"
myXmobarHlColor = "#607a86"
myXmobarUrgentColor = "#89757e"
myXmobarTitleColor = "#deded6"
myFocusFollowsMouse = True
myModMask = mod4Mask

myScratchPads = [ NS "mixer" spawnMixer findMixer manageMixer -- Pavucontrol scratchpad
                , NS "terminal" spawnTerm findTerm manageTerm -- Terminal scratchpad
                , NS "gpmdp" spawnGPM findGPM manageGPM -- Google play music desktop player
                ]
  where
    spawnMixer = "pavucontrol"
    findMixer = className =? "Pavucontrol"
    manageMixer = customFloating $ W.RationalRect l t w h
      where
        h = 0.6
        w = 0.6
        t = (1-h)/2
        l = (1-w)/2

    spawnTerm = myTerminal ++ " -name TermScratchpad"
    findTerm = resource =? "TermScratchpad"
    manageTerm = customFloating $ W.RationalRect l t w h
      where
        h = 0.2
        w = 1
        t = 1-h
        l = 1-w

    spawnGPM = "gpmdp"
    findGPM = className =? "Google Play Music Desktop Player"
    manageGPM = customFloating $ W.RationalRect l t w h
      where
        h = 0.9
        w = 0.9
        t = (1-h)/2
        l = (1-w)/2

myManageHook :: ManageHook
myManageHook =
  manageDocks <+>
  namedScratchpadManageHook myScratchPads <+>
  fullscreenManageHook

myLogHook :: Handle -> X ()
myLogHook xmproc =
  dynamicLogWithPP xmobarPP {
    ppCurrent = xmobarColor myXmobarHlColor ""
  , ppUrgent = xmobarColor myXmobarUrgentColor ""
  , ppHidden = xmobarColor myXmobarTitleColor "" . (\ws -> if ws == "NSP" then "" else ws)
  , ppOutput = hPutStrLn xmproc
  , ppSep = xmobarColor myXmobarHlColor "" " / "
  , ppTitle = xmobarColor myXmobarTitleColor "".shorten 50
  }

myLayout =
  spacing 5 $
  gaps [(U, 20)] $
  avoidStruts $
  tiled ||| Mirror tiled ||| three ||| spiral (6/7) ||| Full
  where
    tiled = ResizableTall nmaster delta ratio slaves
    three = ThreeCol nmaster delta threeRatio
    nmaster = 1
    ratio = 1/2
    delta = 3/100
    slaves = []
    threeRatio = 1/3

myHandleEventHook :: Event -> X All
myHandleEventHook =
  handleEventHook def <+>
  fullscreenEventHook

--These are keys to remove
delKeys XConfig {XMonad.modMask = modMask} =
  [
    ((modMask .|. shiftMask, xK_Return)) -- terminal
  , ((modMask, xK_Return))
  , ((modMask .|. shiftMask, xK_c)) -- Kill
  , ((modMask, xK_p)) -- old dmenu spawn
  ]
newKeys XConfig {XMonad.modMask = modMask} =
  [ ((modMask, xK_u), namedScratchpadAction myScratchPads "terminal")
  , ((modMask, xK_F3), namedScratchpadAction myScratchPads "mixer")
  , ((modMask, xK_F1), namedScratchpadAction myScratchPads "gpmdp")
  , ((modMask, xK_Return), spawn "urxvt")
  , ((modMask .|. shiftMask, xK_Return), promote) -- move focused window to master
  , ((modMask, xK_a), sendMessage MirrorExpand)
  , ((modMask, xK_z), sendMessage MirrorShrink)
  , ((modMask, xK_d), spawn "dmenu_run")
  , ((modMask, xK_q), kill)
  , ((modMask .|. shiftMask, xK_q), recompile True >> restart "xmonad" True)
  , ((0, xF86XK_AudioRaiseVolume), spawn "pactl set-sink-volume 0 +5%")
  , ((0, xF86XK_AudioLowerVolume), spawn "pactl set-sink-volume 0 -5%")
  , ((0, xF86XK_AudioMute), spawn "pactl set-sink-mute 0 toggle")
  , ((0, xF86XK_MonBrightnessUp), spawn "light -A 5")
  , ((0, xF86XK_MonBrightnessDown), spawn "light -U 5")
  , ((0, xK_Print), spawn "scrot")
  , ((0, xF86XK_Launch1), spawn "emacsclient -c")
  , ((modMask, xK_End), spawn "slock") -- Lock the screen
  , ((modMask .|. shiftMask, xK_Escape), confirmPrompt def "Exit to Login Screen" $ io (exitSuccess) ) -- Quit XMonad
  , ((modMask .|. shiftMask, xK_End), confirmPrompt def "Shutdown" $ spawn "shutdown now")
  , ((modMask .|. shiftMask, xK_Home), confirmPrompt def "Restart" $ spawn "reboot")

  -- Keyboard shortcuts to programs
  , ((modMask, xK_F2), spawn "chromium")
  , ((modMask, xK_F4), spawn "pcmanfm")
  ]

myKeys = customKeys delKeys newKeys

main :: IO ()
main = do
  xmproc <- spawnPipe "/usr/bin/xmobar /home/max/.xmobarrc"
  xmonad $ ewmh def
    { borderWidth = myBorderWidth
    , terminal = myTerminal
    , normalBorderColor = myNormalBorderColor
    , focusedBorderColor = myFocusedBorderColor
    , focusFollowsMouse = myFocusFollowsMouse
    , startupHook = setWMName "LG3D"
    , manageHook = myManageHook
    , layoutHook = myLayout
    , logHook = myLogHook xmproc
    , handleEventHook = myHandleEventHook <+> XMonad.Hooks.EwmhDesktops.fullscreenEventHook
    , modMask = myModMask
    , keys = myKeys
    }

