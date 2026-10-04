@echo off
rem Buduje lokalny podglad strony (jak GitHub Pages) i otwiera go w przegladarce.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0tools\preview.ps1"
if errorlevel 1 (pause & exit /b 1)
start "" "%~dp0_preview\index.html"
