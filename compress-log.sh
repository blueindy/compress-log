#!/bin/bash

# Compress each subfolder in a directory and send a log file by email
# Writen: Vorawut Sanitnok
# Version: v1.0


parent_folder="/home/jigx/Downloads/test"
email=""

if [ ! -d "$parent_folder" ]; then
  echo "Error: $parent_folder is not a directory."
  exit 1
fi

logfile="$parent_folder-$(date +"%Y%m%d%H%M%S").log"

echo "Compressing subfolders in $parent_folder..." > "$logfile"

for folder in "$parent_folder"/*; do
  if [ -d "$folder" ]; then
    timestamp=$(date +"%Y%m%d%H%M%S")
    filename="$folder-$timestamp.tar.gz"

    echo "Compressing $folder to $filename..." >> "$logfile"
    tar -czf "$filename" "$folder" | pv >> "$logfile"
    echo "Compression complete." >> "$logfile"

    echo "Removing $folder..." >> "$logfile"
    rm -rf "$folder"
    echo "Removal complete." >> "$logfile"


  fi
done

exit 0

echo "All compressions and removals complete." >> "$logfile"

if [ -n "$email" ]; then
  echo "Sending log file to $email..."
  (
    echo "Subject: Compression and removal log for $parent_folder"
    echo "MIME-Version: 1.0"
    echo "Content-Type: multipart/mixed; boundary=frontier"
    echo ""
    echo "--frontier"
    echo "Content-Type: text/plain"
    echo ""
    cat "$logfile"
    echo ""
    echo "--frontier"
    echo "Content-Type: text/plain; name=$(basename "$logfile")"
    echo "Content-Disposition: attachment; filename=$(basename "$logfile")"
    echo ""
    cat "$logfile"
    echo ""
    echo "--frontier--"
  ) | sendmail "$email"
  echo "Log file sent."
else
  echo "No email address specified, log file not sent."
fi