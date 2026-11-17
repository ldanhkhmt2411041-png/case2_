@echo off
title Khoi dong Backend API (Node.js)
cd /d "%~dp0api"

echo =======================================================
echo DANG KHOI DONG BACKEND API (PORT 5000)...
echo Tu dong ket noi MongoDB Atlas Cloud cua ban
echo =======================================================

if not exist node_modules (
  echo Dang cai dat cac thu vien can thiet (npm install)...
  call npm install
)

echo Dang bat Server...
node server.js
pause
