@echo off
setlocal enabledelayedexpansion

rem Set the directory where the script should look for files
set "directory=C:\Users\keel\Downloads\Compressed\Takeout\Google Photos\2nd half 2021"

rem Loop through each .HEIC and .JPG file in the directory
for %%F in ("%directory%\*.HEIC" "%directory%\*.JPG") do (
    rem Extract the filename without extension
    set "filename=%%~nF"
    
    rem Check if there's a corresponding .MP4 file
    if exist "%directory%\!filename!.MP4" (
        rem Convert the .MP4 file to the desired format (in this case, .MP4)
        echo Converting !filename!.MP4
        ffmpeg -i "%directory%\!filename!.MP4" -c:v copy -c:a copy "%directory%\!filename!_converted.MP4"
        
        rem Replace the original .MP4 file with the converted one
        move /y "%directory%\!filename!_converted.MP4" "%directory%\!filename!.MP4" > nul
    )
)

echo Conversion completed.
pause
