#!/bin/bash
# Batch modify metadata, convert mov to mp4, then converts to motion photos
# Step 1: Update metadata for photos and videos

# Change to the specified directory
cd /sdcard/temp

# Temporary directory to store modified files
temp_dir=$(mktemp -d)

# Find all supported image files in the specified directory and its subdirectories
find /sdcard/temp -type f \( -iname "*.jpg" \) -print0 | while IFS= read -r -d '' file; do

    # Check if the file has CreateDate and ModifyDate metadata
    if [ -z "$(exiftool -b -CreateDate "$file" -ModifyDate "$file" 2>/dev/null)" ]; then

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

        # # Update the date metadata using exiftool
        # exiftool -overwrite_original -P "-CreateDate=$new_date" "-ModifyDate=$new_date" "$file"
		
		# Update the date metadata using exiftool
		exiftool -overwrite_original -P -AllDates="${year}:${month}:${day} ${hour}:${minute}:${second}" -FileModifyDate="${year}:${month}:${day} ${hour}:${minute}:${second}" "$file"

        # Print a message indicating that the file has been modified
        echo "File $file modified."

        # Move the file to the temporary directory
        mv "$file" "$temp_dir/"
        echo "File $file moved to temporary directory."

    else
        echo "File $file already has CreateDate and ModifyDate metadata."
    fi

done

# Move all files from the temporary directory to /sdcard/temp
mv "$temp_dir"/* /sdcard/temp/

echo "All files moved to /sdcard/temp."

# Loop through all files with the specified patterns
for file in *.{JPG,HEIC,GIF,PNG,WEBP,MP4,MOV}; do
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


# Step 2: Convert .MOV files to .MP4 with the same filename as .JPG files
for mov_file in *.MOV; do
    jpg_file="${mov_file%.MOV}.JPG"
    mp4_file="${mov_file%.MOV}.MP4"

    # Check if there is a corresponding .JPG file
    if [ -e "$jpg_file" ]; then
        # Convert .MOV to .MP4
        ffmpeg -i "$mov_file" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "$mp4_file"
        echo "Converted $mov_file to $mp4_file"
    fi
done

# Step .52: Remove .MOV files with the same filename as .>
for mov_file in *.MOV; do
    jpg_file="${mov_file%.MOV}.JPG"
    mp4_file="${mov_file%.MOV}.MP4"

    # Check if there are corresponding .MP4 and .JPG fi>
    if [ -e "$mp4_file" ] && [ -e "$jpg_file" ]; then
        # Remove the .MOV file
        rm "$mov_file"
        echo "Removed $mov_file"
    fi
done


# Step 3: Convert to motion photos
python ~/MotionPhotoMuxer/MotionPhotoMuxer.py --verbose --dir /sdcard/temp --output /sdcard/Google_photos

# Step 4: Remove all .MOV, .MP4 and .JPG with the same filename
find /sdcard/temp -type f -printf "%f\n" | awk -F '.' '{print $1}' | sort | uniq -d | xargs -I{} -n1 find /sdcard/temp -type f -name "{}.*" -delete

# Step 5: Move all videos and photos to /sdcard/Google_photos
mv /sdcard/temp/*.{JPG,MP4,MOV,PNG,HEIC,GIF,WEBP} /sdcard/Google_photos/

echo "All videos and photos moved to /sdcard/Google_photos."

# Step 6: Telegram notification
find . -maxdepth 1 -type f -iname "*.MOV" -not -iname "*.[jJ][pP][gG]" -print0 | xargs -0 -P 3 -n 1 -I {} sh -c 'ffmpeg -i "$1" -vcodec libx264 "${1%.*}.mp4"' sh {} && curl -s -X POST https://api.telegram.org/$chattoken/sendMessage -d chat_id=$chatid -d text="All .MOV files converted to h.264 successfully."
