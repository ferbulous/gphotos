#!/bin/bash

# Declare custom directories
temp_directory="/sdcard/temp2"
googlephotos_directory="/sdcard/Google_photos"
motionphoto_script="~/MotionPhotoMuxer/MotionPhotoMuxer.py"
original_directory="/sdcard/ios"

# Convert .heic to .jpg for corresponding .mov files and move originals
for heic_file in "$temp_directory"/*.heic; do
    if [ -e "$heic_file" ]; then
        filename=$(basename "$heic_file")
        filename_noext="${filename%.*}"
        
        # Check if corresponding .mov file exists
        mov_file="$temp_directory/$filename_noext.mov"
        if [ -e "$mov_file" ]; then
            # Convert .heic to .jpg
            convert "$heic_file" "$temp_directory/$filename_noext.jpg"
            echo "Converted $filename to $filename_noext.jpg"

            # Convert .mov to .mp4
            ffmpeg -i "$mov_file" -c:v copy -c:a aac -strict experimental "$temp_directory/$filename_noext.mp4"
            echo "Converted $filename to $filename_noext.mp4"

            # Move original .heic and .mov files
            mv "$heic_file" "$original_directory/$filename"
            mv "$mov_file" "$original_directory/$filename"
            echo "Moved original $filename to $original_directory"
        else
            echo "No corresponding .mov file found for $filename"
        fi
    fi
done

# Run the motionphoto_script
python "$motionphoto_script" --verbose --dir "$temp_directory" --output "$googlephotos_directory"
