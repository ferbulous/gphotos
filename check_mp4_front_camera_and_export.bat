@echo off
setlocal enabledelayedexpansion

set "source_dir=C:\Users\keel\Downloads\Compressed\Takeout\Google Photos\2nd half 2021"
set "destination_dir=C:\Users\keel\Downloads\Compressed\Takeout\Google Photos\test"

for %%F in ("%source_dir%\*.jpg") do (
    set "jpg_filename=%%~nF"
    set "mp4_filename=!jpg_filename!.mp4"
    if exist "%source_dir%\!mp4_filename!" (
        exiftool -LensID "%%F" | findstr /C:"iPhone 11 front camera" >nul
        if !errorlevel! equ 0 (
            echo Found matching files: "%%F" and "!mp4_filename!"
            copy "%%F" "%destination_dir%"
            ffmpeg -i "%source_dir%\!mp4_filename!" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "%destination_dir%\!mp4_filename!"
rem            copy "%source_dir%\!mp4_filename!" "%destination_dir%"
        )
    )
)

endlocal
