@echo off
rem echo %~d0%~p0upload.ftp

echo SYSTEM> "%~d0%~p0upload.ftp"
echo NaotoKan1946>> "%~d0%~p0upload.ftp"

if /i %~x1 EQU .css (echo cd public/css>> "%~d0%~p0upload.ftp")
if /i %~x1 EQU .js (echo cd public/js>> "%~d0%~p0upload.ftp")
if /i %~x1 EQU .jpg (echo cd public/img>> "%~d0%~p0upload.ftp")
if /i %~x1 EQU .gif (echo cd public/img>> "%~d0%~p0upload.ftp")
if /i %~x1 EQU .png (echo cd public/img>> "%~d0%~p0upload.ftp")
if /i %~x1 EQU .wav (echo cd public/snd>> "%~d0%~p0upload.ftp")
if /i %~x1 EQU .vbs (echo cd public/vbs>> "%~d0%~p0upload.ftp")

echo put %1>> "%~d0%~p0upload.ftp"
echo quit>> "%~d0%~p0upload.ftp"

rem more "%~d0%~p0upload.ftp"

ftp -i -s:"%~d0%~p0upload.ftp" fraterno