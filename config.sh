#!/usr/bin/env bash

# Credit to https://github.com/mathiasbynens/dotfiles for macOS customization

# Close any open System Preferences panes, to prevent them from overriding
# settings we’re about to change
osascript -e 'tell application "System Preferences" to quit'

# Ask for the administrator password upfront
sudo -v

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &

#
# Color key
#

red=$'\e[1;31m'
green=$'\e[1;32m'
yellow=$'\e[1;33m'
blue=$'\e[1;34m'
magenta=$'\e[1;35m'
cyan=$'\e[1;36m'
end=$'\e[0m'

#
# Prep
#

bin_dir="/usr/local/bin"
work_dir="$HOME/work/"
github_dir="$HOME/github/"

printf "%s\n======================================================================\n%s" $yellow $end
printf "%s# Loading mharleydev/config\n%s" $yellow $end
printf "%s======================================================================\n%s" $yellow $end

#
# Creating directories
#

printf "%s\n# Creating directories...\n%s" $yellow $end

printf "%s  - Creating $work_dir...%s"
if [[ ! -e "$work_dir" ]]; then
  mkdir $work_dir
  printf "%s - Success!\n%s" $green $end
else
  printf "%s - Already created\n%s" $cyan $end
fi

printf "%s  - Creating $github_dir...%s"
if [[ ! -e "$github_dir" ]]; then
  mkdir $github_dir
  printf "%s - Success!\n%s" $green $end
else
  printf "%s - Already created\n%s" $cyan $end
fi


#
# Cloning repos
#

printf "%s\n# Cloning repositories...\n%s" $yellow $end

cd $github_dir

github_repos=( mharley.dev )
for repo in "${github_repos[@]}"
do
  printf "%s  - github/$repo%s"
  if [[ ! -e "$github_dir/$repo" ]]; then
    {
      git clone https://github.com/mharleydev/$repo/ $github_dir/$repo/
    } &> /dev/null
    printf "%s - Success!\n%s" $green $end
  else
    printf "%s - Already cloned\n%s" $cyan $end
  fi
done

#
# macOS preferences
#

printf "%s\n# Adjusting macOS...\n%s" $yellow $end
{
  # Dock
  #
  # System Preferences > Dock > Automatically hide and show the Dock:
  defaults write com.apple.dock autohide -bool true
  # System Preferences > Dock > Size:
  defaults write com.apple.dock tilesize -int 36
  # System Preferences > Mission Control > Automatically rearrange Spaces based on most recent use
  defaults write com.apple.dock mru-spaces -bool false
  # Clear out the dock of default icons
  defaults delete com.apple.dock persistent-apps
  defaults delete com.apple.dock persistent-others
  # Don’t show recent applications in Dock
  defaults write com.apple.dock show-recents -bool false

  # Finder
  #
  # Hide desktop icons
  defaults write com.apple.finder CreateDesktop false
  # View as columns
  defaults write com.apple.finder FXPreferredViewStyle -string "clmv"
  # Show path bar
  defaults write com.apple.finder ShowPathbar -bool true
  # Finder: show status bar
  defaults write com.apple.finder ShowStatusBar -bool true
  # Set sidebar icon size to small
  defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 1
  # When performing a search, search the current folder by default
  defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"
  # Prevent .DS_Store files
  defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
  # Set Desktop as the default location for new Finder windows
  # For other paths, use `PfLo` and `file:///full/path/here/`
  defaults write com.apple.finder NewWindowTarget -string "PfDe"
  defaults write com.apple.finder NewWindowTargetPath -string "file://${HOME}/Desktop/"

  # Save & Print
  #
  # Expand save and print modals by default
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode -bool true
  defaults write NSGlobalDomain NSNavPanelExpandedStateForSaveMode2 -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint -bool true
  defaults write NSGlobalDomain PMPrintingExpandedStateForPrint2 -bool true

  # Set a custom wallpaper image. `DefaultDesktop.jpg` is already a symlink, and
  # all wallpapers are in `/Library/Desktop Pictures/`. The default is `Wave.jpg`.
  #rm -rf ~/Library/Application Support/Dock/desktoppicture.db
  #sudo rm -rf /System/Library/CoreServices/DefaultDesktop.jpg
  #sudo ln -s /path/to/your/image /System/Library/CoreServices/DefaultDesktop.jpg

  # System Preferences
  #
  # Disable LCD font smoothing (default 4)
  defaults -currentHost write -globalDomain AppleFontSmoothing -int 0
  # Hot corner: Bottom right, put display to sleep
  defaults write com.apple.dock wvous-br-corner -int 10
  defaults write com.apple.dock wvous-br-modifier -int 0
  # Require password immediately after sleep or screen saver begins
  defaults write com.apple.screensaver askForPassword -int 1
  defaults write com.apple.screensaver askForPasswordDelay -int 0
  # Enable tap to click for trackpad
  defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  # Disable keyboard autocorrect
  defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false
  # Disable Dashboard
  defaults write com.apple.dashboard mcx-disabled -bool true
  # Don’t show Dashboard as a Space
  defaults write com.apple.dock dashboard-in-overlay -bool true
  # Show battery percentage in menu bar
  defaults write com.apple.menuextra.battery ShowPercent -string "YES"

  # Safari
  #
  # Press Tab to highlight each item on a web page
  defaults write com.apple.Safari WebKitTabToLinksPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2TabsToLinks -bool true
  # Show the full URL in the address bar (note: this still hides the scheme)
  defaults write com.apple.Safari ShowFullURLInSmartSearchField -bool true
  # Hide Safari’s bookmarks bar by default
  defaults write com.apple.Safari ShowFavoritesBar -bool false
  # Enable Safari’s debug menu
  defaults write com.apple.Safari IncludeInternalDebugMenu -bool true
  # Enable the Develop menu and the Web Inspector in Safari
  defaults write com.apple.Safari IncludeDevelopMenu -bool true
  defaults write com.apple.Safari WebKitDeveloperExtrasEnabledPreferenceKey -bool true
  defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true
  # Enable “Do Not Track”
  defaults write com.apple.Safari SendDoNotTrackHTTPHeader -bool true

  # Terminal
  #
  # Disable the annoying line marks
  defaults write com.apple.Terminal ShowLineMarks -int 0

  # Restart Finder and Dock (though many changes need a restart/relog)
  killall Finder
  killall Dock

} &> /dev/null

printf "%sDone!\n%s" $green $end

#
# Additional dependencies
#

printf "%s\n# Installing additional dependencies...\n%s" $yellow $end

printf "%s\n  Homebrew:\n%s" $yellow $end

if [[ ! -e "/usr/local/bin/brew" ]]; then
  {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
  } &> /dev/null
  printf "%s - Done!\n%s" $green $end
else
  printf "%s - Already installed\n%s" $cyan $end
fi
