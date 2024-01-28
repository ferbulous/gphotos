#!/bin/bash

# Specify the path to the folder you want to refresh
folder_path="/sdcard/Google_photos_suli"

# Change directory to the specified folder
cd "$folder_path" || exit

# Run the 'am broadcast' command to send a broadcast to the media scanner
am broadcast -a android.intent.action.MEDIA_SCANNER_SCAN_FILE -d "file://${folder_path}"
