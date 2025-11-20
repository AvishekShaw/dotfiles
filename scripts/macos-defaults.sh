#!/usr/bin/env bash

################################################################################
# macos-defaults.sh - Configure macOS system preferences
#
# This script sets up sensible macOS defaults for a development environment.
# Inspired by https://github.com/mathiasbynens/dotfiles
#
# WARNING: This will change system settings. Review before running!
#
# Usage:
#   ./macos-defaults.sh           # Apply all settings
#   ./macos-defaults.sh --dry-run # Preview changes without applying
################################################################################

set -e  # Exit on error

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

DRY_RUN=false

# Parse arguments
for arg in "$@"; do
    case $arg in
        --dry-run)
            DRY_RUN=true
            echo -e "${YELLOW}🔍 DRY RUN MODE - No changes will be made${NC}\n"
            shift
            ;;
    esac
done

print_header() {
    echo -e "\n${BLUE}===================================================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}===================================================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# Execute defaults command (or skip if dry run)
set_default() {
    local description="$1"
    shift

    if [ "$DRY_RUN" = true ]; then
        echo -e "${YELLOW}[DRY RUN]${NC} Would set: $description"
        echo -e "           Command: defaults $*"
    else
        defaults "$@"
        print_success "$description"
    fi
}

################################################################################
# General UI/UX
################################################################################

configure_general() {
    print_header "General UI/UX Settings"

    # Set computer name (as done via System Preferences → Sharing)
    print_info "To set computer name, run manually:"
    echo "  sudo scutil --set ComputerName \"YourName\""
    echo "  sudo scutil --set HostName \"YourName\""
    echo "  sudo scutil --set LocalHostName \"YourName\""
    echo "  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string \"YourName\""
    echo ""

    # Disable the sound effects on boot
    if [ "$DRY_RUN" = false ]; then
        sudo nvram SystemAudioVolume=" " 2>/dev/null || true
        print_success "Disabled boot sound"
    else
        print_info "Would disable boot sound"
    fi

    # Expand save panel by default
    set_default "Expand save panel by default" write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
    set_default "Expand save panel by default (2)" write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true

    # Expand print panel by default
    set_default "Expand print panel by default" write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
    set_default "Expand print panel by default (2)" write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

    # Save to disk (not to iCloud) by default
    set_default "Save to disk by default" write NSGlobalDomain NSDocumentSaveNewDocumentsToCloud -bool false

    # Disable automatic termination of inactive apps
    set_default "Disable automatic termination of inactive apps" write NSGlobalDomain NSDisableAutomaticTermination -bool true

    # Disable the crash reporter
    set_default "Disable crash reporter" write com.apple.CrashReporter DialogType -string "none"

    # Reveal IP address, hostname, OS version, etc. when clicking the clock in the login window
    if [ "$DRY_RUN" = false ]; then
        sudo defaults write /Library/Preferences/com.apple.loginwindow AdminHostInfo HostName 2>/dev/null || true
        print_success "Show system info in login window"
    else
        print_info "Would show system info in login window"
    fi
}

################################################################################
# Keyboard & Input
################################################################################

configure_keyboard() {
    print_header "Keyboard & Input Settings"

    # Set a blazingly fast keyboard repeat rate
    set_default "Set fast key repeat rate" write NSGlobalDomain KeyRepeat -int 2
    set_default "Set short delay until key repeat" write NSGlobalDomain InitialKeyRepeat -int 15

    # Disable press-and-hold for keys in favor of key repeat
    set_default "Disable press-and-hold for keys" write NSGlobalDomain ApplePressAndHoldEnabled -bool false

    # Disable auto-correct
    set_default "Disable auto-correct" write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

    # Enable full keyboard access for all controls (e.g. Tab in modal dialogs)
    set_default "Enable full keyboard access" write NSGlobalDomain AppleKeyboardUIMode -int 3
}

################################################################################
# Trackpad & Mouse
################################################################################

configure_trackpad() {
    print_header "Trackpad & Mouse Settings"

    # Trackpad: enable tap to click
    set_default "Enable tap to click" write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    set_default "Enable tap to click (global)" write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    if [ "$DRY_RUN" = false ]; then
        defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
    fi

    # Trackpad: enable three finger drag
    set_default "Enable three finger drag" write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
    set_default "Enable three finger drag (accessibility)" write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

    # Increase tracking speed
    set_default "Increase tracking speed" write NSGlobalDomain com.apple.trackpad.scaling -float 1.5
}

################################################################################
# Screen
################################################################################

configure_screen() {
    print_header "Screen Settings"

    # Require password immediately after sleep or screen saver begins
    set_default "Require password after screen saver" write com.apple.screensaver askForPassword -int 1
    set_default "Require password immediately" write com.apple.screensaver askForPasswordDelay -int 0

    # Save screenshots to Downloads folder
    set_default "Save screenshots to Downloads" write com.apple.screencapture location -string "${HOME}/Downloads"

    # Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
    set_default "Save screenshots as PNG" write com.apple.screencapture type -string "png"

    # Disable shadow in screenshots
    set_default "Disable shadow in screenshots" write com.apple.screencapture disable-shadow -bool true

    # Enable subpixel font rendering on non-Apple LCDs
    set_default "Enable subpixel font rendering" write NSGlobalDomain AppleFontSmoothing -int 2
}

################################################################################
# Finder
################################################################################

configure_finder() {
    print_header "Finder Settings"

    # Show icons for hard drives, servers, and removable media on the desktop
    set_default "Show hard drives on desktop" write com.apple.finder ShowExternalHardDrivesOnDesktop -bool true
    set_default "Show servers on desktop" write com.apple.finder ShowMountedServersOnDesktop -bool true
    set_default "Show removable media on desktop" write com.apple.finder ShowRemovableMediaOnDesktop -bool true

    # Finder: show all filename extensions
    set_default "Show all filename extensions" write NSGlobalDomain AppleShowAllExtensions -bool true

    # Finder: show status bar
    set_default "Show status bar" write com.apple.finder ShowStatusBar -bool true

    # Finder: show path bar
    set_default "Show path bar" write com.apple.finder ShowPathbar -bool true

    # Display full POSIX path as Finder window title
    set_default "Show full path in title" write com.apple.finder _FXShowPosixPathInTitle -bool true

    # Keep folders on top when sorting by name
    set_default "Keep folders on top" write com.apple.finder _FXSortFoldersFirst -bool true

    # When performing a search, search the current folder by default
    set_default "Search current folder by default" write com.apple.finder FXDefaultSearchScope -string "SCcf"

    # Disable the warning when changing a file extension
    set_default "Disable file extension change warning" write com.apple.finder FXEnableExtensionChangeWarning -bool false

    # Avoid creating .DS_Store files on network or USB volumes
    set_default "Avoid .DS_Store on network volumes" write com.apple.desktopservices DSDontWriteNetworkStores -bool true
    set_default "Avoid .DS_Store on USB volumes" write com.apple.desktopservices DSDontWriteUSBStores -bool true

    # Use list view in all Finder windows by default
    # Four-letter codes for view modes: `icnv`, `clmv`, `glyv`, `Nlsv`
    set_default "Use list view by default" write com.apple.finder FXPreferredViewStyle -string "Nlsv"

    # Show the ~/Library folder
    if [ "$DRY_RUN" = false ]; then
        chflags nohidden ~/Library
        print_success "Show ~/Library folder"
    else
        print_info "Would show ~/Library folder"
    fi

    # Show the /Volumes folder
    if [ "$DRY_RUN" = false ]; then
        sudo chflags nohidden /Volumes 2>/dev/null || true
        print_success "Show /Volumes folder"
    else
        print_info "Would show /Volumes folder"
    fi
}

################################################################################
# Dock
################################################################################

configure_dock() {
    print_header "Dock Settings"

    # Set the icon size of Dock items
    set_default "Set Dock icon size to 48px" write com.apple.dock tilesize -int 48

    # Enable magnification
    set_default "Enable Dock magnification" write com.apple.dock magnification -bool true
    set_default "Set magnification size to 64px" write com.apple.dock largesize -int 64

    # Position the Dock on the left
    set_default "Position Dock on left" write com.apple.dock orientation -string "left"

    # Minimize windows into their application's icon
    set_default "Minimize windows into app icon" write com.apple.dock minimize-to-application -bool true

    # Show indicator lights for open applications
    set_default "Show indicator lights" write com.apple.dock show-process-indicators -bool true

    # Don't animate opening applications
    set_default "Don't animate opening apps" write com.apple.dock launchanim -bool false

    # Speed up Mission Control animations
    set_default "Speed up Mission Control" write com.apple.dock expose-animation-duration -float 0.1

    # Don't automatically rearrange Spaces based on most recent use
    set_default "Don't rearrange Spaces" write com.apple.dock mru-spaces -bool false

    # Automatically hide and show the Dock
    set_default "Auto-hide Dock" write com.apple.dock autohide -bool true

    # Remove the auto-hiding Dock delay
    set_default "Remove Dock show delay" write com.apple.dock autohide-delay -float 0

    # Remove the animation when hiding/showing the Dock
    set_default "Remove Dock animation" write com.apple.dock autohide-time-modifier -float 0

    # Don't show recent applications in Dock
    set_default "Don't show recent apps" write com.apple.dock show-recents -bool false
}

################################################################################
# Safari & WebKit
################################################################################

configure_safari() {
    print_header "Safari & WebKit Settings"

    # Privacy: don't send search queries to Apple
    set_default "Don't send Safari search to Apple" write com.apple.Safari UniversalSearchEnabled -bool false
    set_default "Don't include suggestions" write com.apple.Safari SuppressSearchSuggestions -bool true

    # Show the full URL in the address bar
    set_default "Show full URL in Safari" write com.apple.Safari ShowFullURLInSmartSearchField -bool true

    # Enable the Develop menu and the Web Inspector
    set_default "Enable Safari develop menu" write com.apple.Safari IncludeDevelopMenu -bool true
    set_default "Enable Safari Web Inspector" write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
    set_default "Enable Safari Web Inspector (2)" write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true

    # Enable "Do Not Track"
    set_default "Enable Do Not Track" write com.apple.Safari SendDoNotTrackHTTPHeader -bool true
}

################################################################################
# Terminal
################################################################################

configure_terminal() {
    print_header "Terminal Settings"

    # Only use UTF-8 in Terminal.app
    set_default "Use UTF-8 in Terminal" write com.apple.terminal StringEncodings -array 4

    # Enable Secure Keyboard Entry in Terminal.app
    set_default "Enable secure keyboard in Terminal" write com.apple.terminal SecureKeyboardEntry -bool true
}

################################################################################
# Activity Monitor
################################################################################

configure_activity_monitor() {
    print_header "Activity Monitor Settings"

    # Show the main window when launching Activity Monitor
    set_default "Show main window on launch" write com.apple.ActivityMonitor OpenMainWindow -bool true

    # Show all processes in Activity Monitor
    set_default "Show all processes" write com.apple.ActivityMonitor ShowCategory -int 0

    # Sort Activity Monitor results by CPU usage
    set_default "Sort by CPU usage" write com.apple.ActivityMonitor SortColumn -string "CPUUsage"
    set_default "Sort descending" write com.apple.ActivityMonitor SortDirection -int 0
}

################################################################################
# Text Edit
################################################################################

configure_textedit() {
    print_header "TextEdit Settings"

    # Use plain text mode for new TextEdit documents
    set_default "Use plain text mode" write com.apple.TextEdit RichText -int 0

    # Open and save files as UTF-8 in TextEdit
    set_default "Open files as UTF-8" write com.apple.TextEdit PlainTextEncoding -int 4
    set_default "Save files as UTF-8" write com.apple.TextEdit PlainTextEncodingForWrite -int 4
}

################################################################################
# Main Execution
################################################################################

main() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║              macOS System Preferences Configuration              ║"
    echo "║                                                                  ║"
    echo "║  This will modify your system settings. Review before running!  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    echo -e "${NC}\n"

    if [ "$DRY_RUN" = false ]; then
        print_warning "This will change your macOS system preferences!"
        read -p "Continue? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "Cancelled."
            exit 0
        fi
        echo ""
    fi

    # Close any open System Preferences panes to prevent overriding
    if [ "$DRY_RUN" = false ]; then
        osascript -e 'tell application "System Preferences" to quit' 2>/dev/null || true
    fi

    # Run configuration functions
    configure_general
    configure_keyboard
    configure_trackpad
    configure_screen
    configure_finder
    configure_dock
    configure_safari
    configure_terminal
    configure_activity_monitor
    configure_textedit

    print_header "Configuration Complete"

    if [ "$DRY_RUN" = false ]; then
        print_success "All settings have been applied"
        echo ""
        print_warning "Some changes require a logout/restart to take effect."
        echo ""
        read -p "Restart now? (y/n) " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Restarting..."
            sudo shutdown -r now
        else
            print_info "Please restart your Mac to apply all changes."
        fi
    else
        print_info "This was a dry run. Run without --dry-run to apply changes."
    fi
}

main "$@"
