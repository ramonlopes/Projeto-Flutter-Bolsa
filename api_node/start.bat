@echo off
REM Start sem nodemon
cd /d %~dp0
npm install --production
node src/server.js
