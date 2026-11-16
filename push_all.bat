@echo off
cd /d "%~dp0"
echo =======================================================
echo Pushing all branches to https://github.com/ldanhkhmt2411041-png/case2_KHMT2411041_leducanh
echo =======================================================

echo 1. Pushing feature/sharing...
git push origin feature/sharing

echo 2. Pushing feature/notifications...
git push origin feature/notifications

echo 3. Pushing feature/statistics...
git push origin feature/statistics

echo 4. Pushing main...
git push origin main

echo =======================================================
echo Hoan tat! Kiem tra tren GitHub:
echo https://github.com/ldanhkhmt2411041-png/case2_KHMT2411041_leducanh
echo =======================================================
pause
