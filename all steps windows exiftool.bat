
REM - Step 1  Convert all PNG to PNG
@echo off
setlocal enabledelayedexpansion

REM Set the directory containing the .PNG files
set "directory=C:\Users\keel\Downloads\Compressed\Takeout\Google Photos\2nd half 2021"

REM Change directory to the specified one
cd /d "%directory%"

REM Loop through each .PNG file in the directory
for %%F in (*.PNG) do (
    REM Convert the .PNG file to .PNG format using ImageMagick
    magick "%%F" "%%~nF.PNG"
)

echo Conversion complete.

REM - Step 1.5 - Loop through each .HEIC and .JPG file in the directory
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

echo MP4 Conversion completed.

REM - Step 2 -  convert all HEIC to JPG

REM Convert HEIC files to JPG format
magick mogrify -format jpg *.heic

REM Remove original HEIC files
del *.heic

echo Conversion completed.

REM - Step 3 - rename duplicated .json files script
exiftool -ext json -r -if "$Filename=~/(\.[^.]+)(\(\d+\)).json$$/i" "-Filename<${Filename;s/(\.[^.]+)(\(\d+\)).json$/$2$1.json/}" .


REM - Step 4 - use exiftool to update mp4, mov, jpg, jpeg, gif, png
exiftool -overwrite_original -ext png -ext jpg -ext mp4 -ext gif -ext mov -ext jpeg -d "%%s" -TagsFromFile %%d%%f.%%e.json "-FileCreateDate<${PhotoTakenTimeTimestamp}" "-FileModifyDate<${PhotoTakenTimeTimestamp}" "-SubSecDateTimeOriginal<${PhotoTakenTimeTimestamp}" .

echo metadata updated.

REM - Step 5 - use exiftool to update live videos mp4 & jpg fom heic.json
exiftool -overwrite_original -ext jpg -ext mp4 -d "%%s" -TagsFromFile %%d%%f.HEIC.json "-FileCreateDate<${PhotoTakenTimeTimestamp}" "-FileModifyDate<${PhotoTakenTimeTimestamp}" "-SubSecDateTimeOriginal<${PhotoTakenTimeTimestamp}" .

echo metadata for live photos updated.

REM - Step 6 - use exiftool to update .jpg & .mp4 files with .jpg.json
exiftool -overwrite_original -ext jpg -ext mp4 -d "%%s" -TagsFromFile %%d%%f.JPG.json "-FileCreateDate<${PhotoTakenTimeTimestamp}" "-FileModifyDate<${PhotoTakenTimeTimestamp}" "-SubSecDateTimeOriginal<${PhotoTakenTimeTimestamp}" .

pause