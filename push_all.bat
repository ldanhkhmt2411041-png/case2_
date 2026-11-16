@echo off
cd /d "%~dp0"
echo =======================================================
echo Dang day toan bo cac nhanh len:
echo https://github.com/ldanhkhmt2411041-png/case2_
echo =======================================================

echo 1. Pushing feature/auth...
git push -u origin feature/auth

echo 2. Pushing feature/tasks...
git push -u origin feature/tasks

echo 3. Pushing feature/sharing...
git push -u origin feature/sharing

echo 4. Pushing feature/notifications...
git push -u origin feature/notifications

echo 5. Pushing feature/statistics...
git push -u origin feature/statistics

echo 6. Pushing main...
git push -u origin main

echo =======================================================
echo HOAN TAT! Ban co the kiem tra repo tren GitHub:
echo https://github.com/ldanhkhmt2411041-png/case2_
echo =======================================================
pause
