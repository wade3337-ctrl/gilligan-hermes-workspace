@echo off
REM ==========================================================
REM  GILLIGAN RECOVERY - Windows launcher
REM  Just double-click this file. It runs the recovery script.
REM ==========================================================
title Gilligan Recovery
echo.
echo  Starting Gilligan recovery...
echo.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0bootstrap.ps1"
pause
