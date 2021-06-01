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
github_dir="$HOME/github/"

printf "%s\n======================================================================\n%s" $yellow $end
printf "%s# Loading mharleydev/config\n%s" $yellow $end
printf "%s======================================================================\n%s" $yellow $end

#
# macOS preferences
#

printf "%s\n# Adjusting macOS...\n%s" $yellow $end
{
  # Set computer name (as done via System Preferences → Sharing)
  sudo scutil --set ComputerName "0x339Gungnir"
  sudo scutil --set HostName "0x339Gungnir"
  sudo scutil --set LocalHostName "0x339Gungnir"
  sudo defaults write /Library/Preferences/SystemConfiguration/com.apple.smb.server NetBIOSName -string "0x339Gungnir"

  # Firewall
  #
  # Enable firewall with default options
  sudo defaults write /Library/Preferences/com.apple.alf globalstate -int 1
  # Enable stealthmode
  sudo defaults write /Library/Preferences/com.apple.alf stealthenabled -int 1

  # Set standby delay to 24 hours (default is 1 hour)
  sudo pmset -a standbydelay 86400

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
# Software
#

printf "%s\n# Installing software...\n%s" $yellow $end

# Install brew
printf "%s\n  homebrew\n%s" $yellow $end
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"

# Upgrade brew
printf "%s\n  brew upgrade\n%s" $yellow $end
brew upgrade

# Install tools
printf "%s\n  git\n%s" $yellow $end
brew install git
export PATH=/usr/local/bin:$PATH
printf "%s\n  1password\n%s" $yellow $end
brew install --cask 1password
printf "%s\n  mullvadvpn\n%s" $yellow $end
brew install --cask mullvadvpn
printf "%s\n  firefox\n%s" $yellow $end
brew install --cask firefox
printf "%s\n  bartender\n%s" $yellow $end
brew install --cask bartender
printf "%s\n  tweetbot\n%s" $yellow $end
brew install --cask tweetbot
printf "%s\n  signal\n%s" $yellow $end
brew install --cask signal
printf "%s\n  moneydance\n%s" $yellow $end
brew install --cask moneydance
printf "%s\n  littlesnitch\n%s" $yellow $end
brew install --cask little-snitch
printf "%s\n  micro-snitch\n%s" $yellow $end
brew install --cask micro-snitch
printf "%s\n  visual-studio-code\n%s" $yellow $end
brew install --cask visual-studio-code 
printf "%s\n  acorn\n%s" $yellow $end
brew install --cask acorn
printf "%s\n  imageoptim\n%s" $yellow $end
brew install --cask imageoptim
printf "%s\n  blockblock\n%s" $yellow $end
brew install --cask blockblock
printf "%s\n  backblaze\n%s" $yellow $end
brew install --cask backblaze

# Remove outdated versions from the cellar.
printf "%s\n  brew cleanup\n%s" $yellow $end
brew cleanup

printf "%sDone!\n%s" $green $end

#
# Copying dotfiles
#

printf "%s\n# Copying dotfiles...\n%s" $yellow $end

dotfiles=( gitconfig gitignore bash_profile )
for file in "${dotfiles[@]}"
do
  printf "%s  - .$file%s"
  if [[ ! -e "$HOME/.$file" ]]; then
    {
      curl https://raw.githubusercontent.com/mharleydev/config/master/.$file > $HOME/.$file
    } &> /dev/null
    printf "%s - Success!\n%s" $green $end
  else
    printf "%s - Already present\n%s" $cyan $end
  fi
done
