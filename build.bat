@echo off
cd /d "%~dp0"
bazelisk build -c opt //:butteraugli
if %ERRORLEVEL% equ 0 (
  echo.
  echo Built: bazel-bin\butteraugli.exe
)
