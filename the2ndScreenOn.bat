@echo off

:: Primary monitor is at X=0, Y=0, resolution 3440x1440.  TV is X=2007, Y=-2160, resolution 3072x1728. https://web.telegram.org/ 
start brave.exe https://www.youtube.com  --new-window --window-position=3000,-1700 --start-fullscreen --user-data-dir="C:\Users\%USERNAME%\AppData\Local\BraveSoftware\Brave-Browser\User Data\Profile 2"