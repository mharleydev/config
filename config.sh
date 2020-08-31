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
