#!/bin/bash

# Declare custom directories
temp_directory="/sdcard/temp2"
googlephotos_directory="/sdcard/Google_photos"
motionphoto_script="~/MotionPhotoMuxer/MotionPhotoMuxer.py"
original_directory="/sdcard/ios"

# Convert .heic to .jpg for corresponding .mov files
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
        else
            echo "No corresponding .mov file found for $filename"
        fi
    fi
done

# Run the motionphoto_script
python "$motionphoto_script" --verbose --dir "$temp_directory" --output "$googlephotos_directory"

# Remove original .heic, .mov, and .mp4 files
for filename_noext in "$temp_directory"/*.jpg; do
    if [ -e "$filename_noext" ]; then
        rm "$temp_directory/$filename_noext.jpg"
        rm "$temp_directory/$filename_noext.mp4"
        rm "$original_directory/$filename_noext.heic"
        rm "$original_directory/$filename_noext.mov"
        echo "Removed original files for $filename_noext"
    fi
done
