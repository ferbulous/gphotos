#!/bin/bash

# Declare Telegram variables
tg_token="600xxxx:AAHKNxxx"
chat_id="10xxx"

cd /sdcard/temp2

# # Step 1: Convert .MOV files to .MP4 with the same filename as .JPG files
# for mov_file in *.{MOV,mov}; do
    # jpg_file="${mov_file%.MOV}.JPG"
    # jpg_file_lower="${mov_file%.mov}.jpg"
    # mp4_file="${mov_file%.MOV}.MP4"

    # # Check if there is a corresponding .JPG file
    # if [ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]; then
        # # Convert .MOV to .MP4
        # ffmpeg -i "$mov_file" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "$mp4_file"
        # echo "Converted $mov_file to $mp4_file"
    # fi
# done

# # Step 2: Remove .MOV files with the same filename as .MP4 and .JPG files
# for mov_file in *.{MOV,mov}; do
    # jpg_file="${mov_file%.MOV}.JPG"
    # jpg_file_lower="${mov_file%.mov}.jpg"
    # mp4_file="${mov_file%.MOV}.MP4"

    # # Check if there are corresponding .MP4 and .JPG files
    # if ([ -e "$mp4_file" ] || [ -e "${mp4_file,,}" ]) && ([ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]); then
        # # Remove the .MOV file
        # rm "$mov_file"
        # echo "Removed $mov_file"
    # fi
# done

# #this converts both uppercase & lowercase but outputs lowercase

# # Step 1: Convert .MOV files to .MP4 with the same filename as .JPG files
# for mov_file in *.{MOV,mov}; do
    # jpg_file="${mov_file%.MOV}.JPG"
    # jpg_file_lower="${mov_file%.mov}.jpg"
    # mp4_file="${mov_file%.MOV}.MP4"
    # mp4_file_lower="${mov_file%.mov}.mp4"  # Fix: Add the lowercase version of the mp4_file

    # # Check if there is a corresponding .JPG file
    # if [ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]; then
        # # Convert .MOV to .MP4
        # ffmpeg -i "$mov_file" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "$mp4_file_lower"  # Fix: Use mp4_file_lower
        # echo "Converted $mov_file to $mp4_file_lower"
    # fi
# done

# # Step 2: Remove .MOV files with the same filename as .MP4 and .JPG files
# for mov_file in *.{MOV,mov}; do
    # jpg_file="${mov_file%.MOV}.JPG"
    # jpg_file_lower="${mov_file%.mov}.jpg"
    # mp4_file="${mov_file%.MOV}.MP4"
    # mp4_file_lower="${mov_file%.mov}.mp4"  # Fix: Add the lowercase version of the mp4_file

    # # Check if there are corresponding .MP4 and .JPG files
    # if ([ -e "$mp4_file" ] || [ -e "$mp4_file_lower" ]) && ([ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]); then
        # # Remove the .MOV file
        # rm "$mov_file"
        # echo "Removed $mov_file"
    # fi
# done

# #attempt 3 - still outputs IMG_xx.mov.MP4
# # Step 1: Convert .MOV files to .MP4 with the same filename as .JPG files
# for mov_file in *.{MOV,mov}; do
    # jpg_file="${mov_file%.MOV}.JPG"
    # jpg_file_lower="${mov_file%.mov}.jpg"
    # mp4_file="${mov_file%.MOV}.MP4"
    # mp4_file_lower="${mov_file%.mov}.mp4"  # Fix: Add the lowercase version of the mp4_file

    # # Check if there is a corresponding .JPG file
    # if [ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]; then
        # # Convert .MOV to .MP4
        # ffmpeg -i "$mov_file" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "$mp4_file"  # Fix: Use mp4_file instead of mp4_file_lower
        # echo "Converted $mov_file to $mp4_file"
    # fi
# done

# # Step 2: Remove .MOV files with the same filename as .MP4 and .JPG files
# for mov_file in *.{MOV,mov}; do
    # jpg_file="${mov_file%.MOV}.JPG"
    # jpg_file_lower="${mov_file%.mov}.jpg"
    # mp4_file="${mov_file%.MOV}.MP4"
    # mp4_file_lower="${mov_file%.mov}.mp4"  # Fix: Add the lowercase version of the mp4_file

    # # Check if there are corresponding .MP4 and .JPG files
    # if ([ -e "$mp4_file" ] || [ -e "$mp4_file_lower" ]) && ([ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]); then
        # # Remove the .MOV file
        # rm "$mov_file"
        # echo "Removed $mov_file"
    # fi
# done

# attempt 5 - works, just outputs the filename with uppercase MP4
# Step 1: Convert .MOV files to .MP4 with the same filename as .JPG files
for mov_file in *.{MOV,mov}; do
    jpg_file="${mov_file%.MOV}.JPG"
    jpg_file_lower="${mov_file%.mov}.jpg"
    mp4_file="${mov_file%.*}.MP4"  # Update this line to remove the previous extension

    # Check if there is a corresponding .JPG file
    if [ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]; then
        # Convert .MOV to .MP4
        ffmpeg -i "$mov_file" -c:v libx264 -preset medium -crf 23 -c:a aac -strict experimental -b:a 192k "$mp4_file"
        echo "Converted $mov_file to $mp4_file"
    fi
done

# Step 2: Remove .MOV files with the same filename as .MP4 and .JPG files
for mov_file in *.{MOV,mov}; do
    jpg_file="${mov_file%.MOV}.JPG"
    jpg_file_lower="${mov_file%.mov}.jpg"
    mp4_file="${mov_file%.*}.MP4"  # Update this line to remove the previous extension

    # Check if there are corresponding .MP4 and .JPG files
    if ([ -e "$mp4_file" ] || [ -e "${mp4_file,,}" ]) && ([ -e "$jpg_file" ] || [ -e "$jpg_file_lower" ]); then
        # Remove the .MOV file
        rm "$mov_file"
        echo "Removed $mov_file"
    fi
done


# Step next
python ~/MotionPhotoMuxer/MotionPhotoMuxer.py --verbose --dir /sdcard/temp2 --output /sdcard/test3

# Step 4: Remove all .MOV, .MP4 and .JPG with the same filename
find /sdcard/temp2 -type f -printf "%f\n" | awk -F '.' '{print $1}' | sort | uniq -d | xargs -I{} -n1 find /sdcard/temp2 -type f -name "{}.*" -delete

# # Step 5: Move all videos and photos to /sdcard/Google_photos
# mv /sdcard/temp2/*.{JPG,MP4,MOV,PNG,HEIC,GIF,WEBP} /sdcard/Google_photos_suli/

# Step 5: Move all videos and photos to /sdcard/Google_photos
mv /sdcard/temp2/*.{JPG,jpg,MP4,mp4,MOV,mov,PNG,png,HEIC,heic,GIF,gif,WEBP,webp} /sdcard/Google_photos_suli/

echo "All videos and photos moved to /sdcard/Google_photos_suli."

# Step 6: Telegram notification
find "$temp_directory" -maxdepth 1 -type f -iname "*.MOV" -not -iname "*.[jJ][pP][gG]" -print0 | xargs -0 -P 3 -n1 -I {} sh -c 'ffmpeg -i "$1" -vcodec libx264 "${1%.*}.mp4"' sh {} && curl -s -X POST https://api.telegram.org/bot"$tg_token"/sendMessage -d chat_id="$chat_id" -d text="All .MOV files converted to h.264 successfully."

# # step 7
# am broadcast -a foo.bar.baz.intent.action.MY_SCRIPT_COMPLETED
