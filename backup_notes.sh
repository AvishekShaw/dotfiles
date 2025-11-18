#! /bin/bash
set -ex

log_file_dest="/Users/egregious/Code/dotfiles/backup_log_file"
path1="/Users/egregious/Documents/notes/"
path2="gdrive:Documents/Notes" 

echo "-----------------starting backup of notes---------------">>"$log_file_dest"
rclone copy --verbose --log-file $log_file_dest "$path1" "$path2"
echo "-------------------------------------------------------">>"$log_file_dest"
