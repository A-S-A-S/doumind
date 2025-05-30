@echo off

echo Greetings, %USERNAME%
echo What are you grateful for today?
set /p entry=
echo [%date% %time%] %entry% >> tmp/gratitude_diary.txt