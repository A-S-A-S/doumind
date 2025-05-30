@echo off

schtasks /Create /sc weekly /d MON,TUE,WED,THU,FRI /tn "Gratitude Scheduler" /tr "%cd%\Scripts\gratitude.bat" /st 21:00