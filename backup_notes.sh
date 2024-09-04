#! /bin/bash
set -ex

log_file_dest="/home/avishek/Code/Shell/backup_log_file"
path1="/home/avishek/Documents/Notes/"
path2="Gdrive:Documents/Notes" 

echo "-----------------starting backup of tex---------------">>"$log_file_dest"
rclone copy --verbose --log-file $log_file_dest "$path1" "$path2"
echo "-------------------------------------------------------">>"$log_file_dest"
