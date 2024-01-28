#!/bin/bash

# Declare custom directories
temp_directory="/sdcard/temp2" 
googlephotos_directory="/sdcard/Google_photos_suli" 
motionphoto_script="~/MotionPhotoMuxer/MotionPhotoMuxer.py"  

# Step 1: Update metadata for photos and videos

# Change to the specified directory
cd "$temp_directory"

# Temporary directory to store modified files
temp_dir=$(mktemp -d)

# Find all .mp4 files (case-insensitive) in the specified directory and its subdirectories & repairs the files with truncated warning error
find "$temp_directory" -type f -iname "*.mp4" -print0 | while IFS= read -r -d '' file; do

    # Check if exiftool reports a Truncated warning
    if exiftool -error "$file" 2>&1 | grep -q "Truncated"; then
        echo "Exiftool reported a Truncated warning for $file."

        # Fix the problematic file using ffmpeg
        if ffmpeg -i "$file" -c copy -strict experimental "${file%.mp4}_temp.mp4" 2>&1 | grep -q "Error"; then
            echo "Error fixing $file with ffmpeg:"
            ffmpeg -i "$file" -c copy -strict experimental "${file%.mp4}_temp.mp4"
            echo "Skipping."
        else
            echo "File $file fixed using ffmpeg."
            # Replace the original file with the fixed one
            mv "${file%.mp4}_temp.mp4" "$file"
        fi
    else
        echo "Exiftool did not report a Truncated warning for $file. No action taken."
    fi

done

# Find all supported image files in the specified directory and its subdirectories and updates metadata if missing
find "$temp_directory" -type f \( -iname "*.jpg" -o -iname "*.png" -o -iname "*.heic" -o -iname "*.gif" -o -iname "*.mp4" -o -iname "*.mov" -o -iname "*.webp" \) -print0 | while IFS= read -r -d '' file; do

    # Check if both CreateDate and ModifyDate are either "0000:00:00 00:00:00" or empty
    create_date=$(exiftool -b -CreateDate "$file" 2>/dev/null)
    modify_date=$(exiftool -b -ModifyDate "$file" 2>/dev/null)

    if [ -z "$create_date" ] && [ -z "$modify_date" ]; then

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

    elif [ "$create_date" == "0000:00:00 00:00:00" ] && [ "$modify_date" == "0000:00:00 00:00:00" ]; then
        # Print a message indicating that the file already has invalid metadata
        echo "File $file already has invalid CreateDate and ModifyDate metadata."
		
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

    else
        # Print a message indicating that the file already has valid metadata
        echo "File $file already has valid CreateDate and ModifyDate metadata."
    fi

done

# Move all files from the temporary directory to /sdcard/temp2
mv "$temp_dir"/* "$temp_directory"

echo "All files moved to $temp_directory."

# Loop through all files with the specified patterns
for file in "$temp_directory"/*.{JPG,jpg,HEIC,heic,GIF,gif,PNG,png,WEBP,webp,MP4,mp4,MOV,mov}; do
    # Check if the file exists
    if [ -e "$file" ]; then
        # Extract the new filename by removing the first 20 characters
        new_filename="${file:20}"
        
        # Rename the file
        mv "$file" "$new_filename"
        
        echo "Renamed $file to $new_filename"
    else
        echo "No files found with the pattern: $file"
    fi
done

#this converts both uppercase & lowercase but outputs lowercase

# Step 1: Convert .MOV files to .MP4 with the same filename as .JPG files
for mov_file in "$temp_directory"/*.{MOV,mov}; do
    jpg_file="${mov_file%.MOV}.JPG"
    jpg_file_lower="${mov_file%.mov}.jpg"
    mp4_file="${mov_file%.MOV}.MP4"
    mp4_file_lower="${mov_file%.mov}.mp4"  # Fix: Add the lowercase version of the mp4_file

    # Check if there is a corresponding .JPG file
    if [ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]; then
        # Convert .MOV to .MP4
        ffmpeg -i "$mov_file" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "$mp4_file_lower"  # Fix: Use mp4_file_lower
        echo "Converted $mov_file to $mp4_file_lower"
    fi
done

# Step 2: Remove .MOV files with the same filename as .MP4 and .JPG files
for mov_file in "$temp_directory"/*.{MOV,mov}; do
    jpg_file="${mov_file%.MOV}.JPG"
    jpg_file_lower="${mov_file%.mov}.jpg"
    mp4_file="${mov_file%.MOV}.MP4"
    mp4_file_lower="${mov_file%.mov}.mp4"  # Fix: Add the lowercase version of the mp4_file

    # Check if there are corresponding .MP4 and .JPG files
    if ([ -e "$mp4_file" ] || [ -e "$mp4_file_lower" ]) && ([ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]); then
        # Remove the .MOV file
        rm "$mov_file"
        echo "Removed $mov_file"
    fi
done

# Step 3: Convert to motion photos for suli
python "$motionphoto_script" --verbose --dir "$temp_directory" --output "$googlephotos_directory"

# Step 4: Remove all .MOV, .MP4, and .JPG with the same filename
find "$temp_directory" -type f -printf "%f\n" | awk -F '.' '{print $1}' | sort | uniq -d | xargs -I{} -n1 find "$temp_directory" -type f -name "{}.*" -delete

# Step 5: Move all videos and photos to /sdcard/Google_photos
mv "$temp_directory"/*.{JPG,jpg,MP4,mp4,MOV,mov,PNG,png,HEIC,heic,GIF,gif,WEBP,webp} "$googlephotos_directory"

echo "All videos and photos moved to $googlephotos_directory."

# Step 6: Telegram notification
find "$temp_directory" -maxdepth 1 -type f -iname "*.MOV" -not -iname "*.[jJ][pP][gG]" -print0 | xargs -0 -P 3 -n1 -I {} sh -c 'ffmpeg -i "$1" -vcodec libx264 "${1%.*}.mp4"' sh {} && curl -s -X POST https://api.telegram.org/$chattoken/sendMessage -d chat_id=$chatid -d text="All .MOV files converted to h.264 successfully."

# Step 7: broadcast intent to automate app
am broadcast -a foo.bar.baz.intent.action.MY_SCRIPT_COMPLETED
