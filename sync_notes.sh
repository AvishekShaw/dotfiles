#!/bin/sh

# Determine the environment based on the output of whoami
if [ "$(whoami)" = "egregious" ]; then
    # macOS
    NOTES_DIR="$HOME/Documents/notes"
    GIT_CMD="git"
elif [ "$(whoami)" = "mobile" ]; then
    # a-shell on iOS
    NOTES_DIR="~Documents"
    GIT_CMD="lg2"
else
    echo "Unsupported environment"
    exit 1
fi

# Change to the notes directory
cd "$NOTES_DIR" || exit 1

# Add all .md, .png, and .pdf files
find . -type f \( -name "*.md" -o -name "*.png" -o -name "*.pdf" \) -print0 | xargs -0 "$GIT_CMD" add

# Add deleted files
"$GIT_CMD" ls-files --deleted -z | xargs -0 "$GIT_CMD" add

# Commit changes
"$GIT_CMD" commit -m "Sync on $(date)"

# Pull changes from remote
"$GIT_CMD" pull origin master

# Push changes to remote
"$GIT_CMD" push origin master