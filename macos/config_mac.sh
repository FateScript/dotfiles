
# vscode
echo "VSCode: Disable press and hold for keys in favor of key repeat"
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
# to re-enable, execute the following cmd
# defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool true

# iterm2
echo "iTerm2: Don’t display the annoying prompt when quitting iTerm"
defaults write com.googlecode.iterm2 PromptOnQuit -bool false

# TextEdit
echo "TextEdit: Set tab width to 4 instead of the default 8"
defaults write com.apple.TextEdit "TabWidth" '4'

# Safari
echo "Safari: Configure Google as main search engine"
defaults write com.apple.Safari SearchProviderIdentifier -string "com.google.Chrome"
defaults write NSGlobalDomain NSProviderIdentifier -string "com.google.Chrome"
