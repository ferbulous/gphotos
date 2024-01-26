#!/bin/bash

# Step 1: Update metadata for photos and videos (for create date & modify date 0000:00:00 00:00:00)

# Change to the specified directory
cd /sdcard/temps

# Temporary directory to store modified files
temp_dir=$(mktemp -d)

# Find all supported image files in the specified directory and its subdirectories
find /sdcard/temps -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.heic" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' file; do

    # Check if both CreateDate and ModifyDate are "0000:00:00 00:00:00"
    create_date=$(exiftool -b -CreateDate "$file" 2>/dev/null)
    modify_date=$(exiftool -b -ModifyDate "$file" 2>/dev/null)

    if [ "$create_date" == "0000:00:00 00:00:00" ] && [ "$modify_date" == "0000:00:00 00:00:00" ]; then

        # Extract information from the filename
        filename=$(basename "$file")
        year=$(echo "$filename" | cut -d'-' -f1)
        month=$(echo "$filename" | cut -d'-' -f2)
        day=$(echo "$filename" | cut -d'-' -f3 | cut -d'_' -f1)
        hour=$(echo "$filename" | cut -d'_' -f2 | cut -d'-' -f1)
        minute=$(echo "$filename" | cut -d'-' -f2)
        second=$(echo "$filename" | cut -d'-' -f3 | cut -d'_' -f2 | cut -d'.' -f1)

        # Construct the new date
        new_date="${year}-${month}-${day} ${hour}:${minute}:${second}"

        # Print the file path and the new date to help identify any issues
        echo "Processing $file with new date: $new_date"

        # Update the date metadata using exiftool
        exiftool -overwrite_original -P -AllDates="${year}:${month}:${day} ${hour}:${minute}:${second}" -FileModifyDate="${year}:${month}:${day} ${hour}:${minute}:${second}" "$file"

        # Print a message indicating that the file has been modified
        echo "File $file modified."

        # Move the file to the temporary directory
        mv "$file" "$temp_dir/"
        echo "File $file moved to temporary directory."

    else
        echo "File $file already has valid CreateDate and ModifyDate metadata."
    fi

done
