@echo off
title Khoi dong Ung dung TaskManager (Flutter)
cd /d "%~dp0TaskManager"

echo =======================================================
echo DANG KHOI DONG FLUTTER TASKMANAGER TREN CHROME...
echo =======================================================

echo Dang kiem tra goi thu vien Flutter (flutter pub get)...
call flutter pub get

echo Dang mo ung dung tren Chrome...
flutter run -d chrome
pause
