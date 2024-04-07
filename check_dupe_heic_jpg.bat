@echo off
setlocal enabledelayedexpansion

rem Set the directory where you want to search for files
set "directory=C:\Users\keel\Downloads\Compressed\Takeout\Google Photos\test"

rem Set the output text file
set "output_file=output.txt"

rem Initialize the output file
echo Files with both .heic and .jpg extensions: > %output_file%
echo ------------------------------------------- >> %output_file%

rem Loop through each .heic file in the directory
for %%F in ("%directory%\*.heic") do (
    rem Extract the filename without extension
    set "filename=%%~nF"
    
    rem Check if a corresponding .jpg file exists
    if exist "%directory%\!filename!.jpg" (
        echo Found: %%~nxF >> %output_file%
    )
)

rem Notify user about completion
echo Task completed. Please check %output_file%

endlocal
