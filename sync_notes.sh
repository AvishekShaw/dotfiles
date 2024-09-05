#!/bin/sh

dashes() {
    local length=$1
    local dashes=$(printf "%*s" $length "")
    echo "${dashes// /-}"
}

# Determine the environment based on the output of whoami
if [ "$(whoami)" = "egregious" ]; then
    # macOS
    NOTES_DIR="$HOME/Documents/notes"
    GIT_CMD="git"
    cd "$NOTES_DIR" || exit 1
elif [ "$(whoami)" = "mobile" ]; then
    # a-shell on iOS
    # NOTES_DIR="~Documents"
    GIT_CMD="lg2"
else
    echo "Unsupported environment"
    exit 1
fi

# Change to the notes directory

# Add all .md, .png, and .pdf files
find . -type f \( -name "*.md" -o -name "*.png" -o -name "*.pdf" \) -print0 | xargs -0 "$GIT_CMD" add

# Add deleted files
"$GIT_CMD" ls-files --deleted -z | xargs -0 "$GIT_CMD" add
dashes 50

# Commit changes
"$GIT_CMD" commit -m "Sync on $(date)" && echo "Changes committed"
dashes 50

# Pull changes from remote
"$GIT_CMD" pull origin master && echo "Changes pulled"
dashes 50
# Push changes to remote
"$GIT_CMD" push origin master && echo "Changes pushed"
dashes 50