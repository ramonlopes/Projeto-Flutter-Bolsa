@echo off
REM Executar no Windows PowerShell ou CMD: start-dev.bat
cd /d %~dp0
npm install
npx nodemon src/server.js
