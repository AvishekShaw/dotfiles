#! /bin/bash

OBS_HOME=$HOME/Documents/notes
cd $OBS_HOME

echo "-----------------starting sync of obsidian notes---------------"
echo $(date +"%D %T") 

find . -type f \( -name "*.md" -o -name "*.png" -o -name "*.pdf" \) -print0 | xargs -0 git add
git ls-files --deleted -z | xargs -0 git add

git commit -m "updated $(date)"

git pull origin master
git push origin master

echo "-------------------------------------------------------"
