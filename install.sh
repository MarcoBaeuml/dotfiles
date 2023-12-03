#!/bin/bash

apps=('git' 'fish')
cask_apps=('alfred' 'rectangle' 'itsycal' 'mac-mouse-fix' 'visual-studio-code' 'iterm2' 'utm' 'microsoft-teams' 'microsoft-remote-desktop' \
'licecap' 'licecap' 'telegram' 'whatsapp' 'brave-browser' 'openvpn-connect' 'spotify' 'aldente')
dock_apps=('System Settings' 'Brave Browser' 'Visual Studio Code' 'Spotify' 'iTerm' 'Telegram' 'WhatsApp')
app_store_apps=( 'Yoink' 'WireGuard' 'Pixelmator Pro')

defaults=(\
'-g ApplePressAndHoldEnabled -bool false' \
'-g InitialKeyRepeat -int 15' \
'-g KeyRepeat -int 2' \
'com.apple.dock autohide -bool true' \
'com.apple.dock orientation -string left' \
'com.apple.dock autohide-delay -int 0' \
'com.apple.dock autohide-time-modifier -float 0.8' \
'com.apple.finder AppleShowAllFiles -bool true' \
'com.apple.finder FXEnableExtensionChangeWarning -bool false' \
'com.apple.finder FXPreferredViewStyle -string clmv' \
'com.apple.finder QuitMenuItem -bool true' \
'NSGlobalDomain AppleShowAllExtensions -bool true' \
'com.apple.finder AppleShowAllFiles -bool true' \
'com.apple.finder ShowPathbar -bool true' \
'com.apple.finder _FXSortFoldersFirst -bool true' \
'com.apple.finder FXDefaultSearchScope -string SCcf' \
'com.apple.finder FXRemoveOldTrashItems -bool true' \
'com.apple.menuextra.clock IsAnalog -bool true' \
'com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0' \
'com.apple.AppleMultitouchTrackpad Dragging -bool true' \
'com.apple.TextEdit RichText -bool false' \
'NSGlobalDomain ApplePressAndHoldEnabled -bool false' \
'NSGlobalDomain com.apple.keyboard.fnState -bool true' \
)

manual_steps=(\
'swap control and caps lock'\
'adjust Menu Bar (screenshot ) & configure Itsycal (format: "       EEEE, dd.MM | HH:mm")'\
'configure Finder sidebar (screenshot)'\
'go through every app and configure it'\
'remove every Widget (click on clock)'\
)

prompt_confirm() {
	read -r -p "$1 [y/N] " response
	case "$response" in
		[yY][eE][sS]|[yY]) 
			return 0
			;;
		*)
			echo "exiting..."
			exit 0
			;;
	esac
}

print_error() {
    local RED='\033[0;31m'
    local NC='\033[0m'

    echo -e "${RED}$1${NC}"
}

add_app_to_dock() {

    if [ -z "$1" ]; then
        print_error "No application name provided"
        return 1
    fi

    app_name="$1"
    app_path=$(mdfind "kMDItemKind == 'Application'" | grep "$app_name" | head -n 1)

    if [ -z "$app_path" ]; then
        print_error "Application not found: $app_name"
        return 1
    fi

    # Add the app to the Dock
    defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app_path</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
}

prompt_confirm "This will install the dotfiles in this repo. Continue?"

# install homebrew
if ! command -v brew &> /dev/null
then
    echo "Installing homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# install homebrew apps

# install apps
for app in "${apps[@]}"
do
    echo "Installing $app..."
    brew install $app
done

# install cask apps
for app in "${cask_apps[@]}"
do
    echo "Installing cask $app..."
    brew install --cask $app
done

# Make fish the default shell
if ! grep -Fxq "$(which fish)" /etc/shells; then
    echo $(which fish) >> /etc/shells
fi
chsh -s $(which fish)

# install app store apps
echo "Please install the following app store apps:"
for app in "${app_store_apps[@]}"
do
    echo - $app
done

prompt_confirm "Continue? Defaults will now be applied."

# adding defaults
for default in "${defaults[@]}"
do
    echo "Applying $default..."
    defaults write $default
done

# add apps to the dock
defaults write com.apple.dock persistent-apps -array
defaults write com.apple.dock persistent-others -array
for app in "${dock_apps[@]}"
do
    echo "Adding $app to the dock..."
    add_app_to_dock "/$app.app"
done

# show manuel steps
echo "Please do the following steps manually:"
for step in "${manual_steps[@]}"
do
    echo - $step
done

echo "finished"