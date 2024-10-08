#!/bin/sh

# dashes() {
#     local length=$1
#     local dashes=$(printf "%*s" $length "")
#     echo "${dashes// /-}"
# }


dashes() {
    local length=$1
    local dashes=$(printf "%*s" $length "")
    echo "${dashes}" | tr ' ' '-'
}

GIT_CMD="git"
# Determine the environment based on the output of whoami
if [ "$(whoami)" = "egregious" ]; then
    # macOS
    NOTES_DIR="$HOME/Documents/notes"
    # GIT_CMD="git"
    echo "This is darwin environment. Syncing notes from $NOTES_DIR"
# elif [ "$(whoami)" = "mobile" ]; then
elif [ "$(whoami)" = "mobile" ]; then

    # a-shell on iOS
    NOTES_DIR="notes"
    # GIT_CMD="lg2"
    echo "This is iOS environment"
else
    echo "Unsupported environment or directory"
    exit 1
fi

# Change to the notes directory
cd "$NOTES_DIR" || exit 1

# Add all .md, .png, and .pdf files
# find . -type f \( -name "*.md" -o -name "*.png" -o -name "*.pdf" \) -print0 | xargs -0 "$GIT_CMD" add

# Add deleted files
# "$GIT_CMD" ls-files --deleted -z | xargs -0 "$GIT_CMD" add

# Remove deleted files from Git index
# find . -type f \( -name "*.md" -o -name "*.png" -o -name "*.pdf" \) -print0 | while read -d '' file; do
#   if [ ! -e "$file" ]; then
#     "$GIT_CMD" add "$file"
#   fi
# done
# dashes 50

# Add all files
"$GIT_CMD" add . && echo "All files added"
dashes 50

# Commit changes
"$GIT_CMD" commit -m "Sync from $(whoami)" && echo "Changes committed"
dashes 50


if [ "$(whoami)" = "egregious" ]; then
    # Pull changes from remote
    "$GIT_CMD" pull origin master && echo "Changes pulled"
    dashes 50

    # Push changes to remote
    "$GIT_CMD" push origin master && echo "Changes pushed"
    dashes 50
elif [ "$(whoami)" = "mobile" ]; then

   # Pull changes from remote
    "$GIT_CMD" pull origin && echo "Changes pulled"
    dashes 50

    # Push changes to remote
    "$GIT_CMD" push origin && echo "Changes pushed"
    dashes 50
else
    echo "Unsupported environment or directory"
    exit 1
fi

# Pull changes from remote
# "$GIT_CMD" pull origin master && echo "Changes pulled"
# dashes 50

# Push changes to remote
# "$GIT_CMD" push origin master && echo "Changes pushed"
# dashes 50