#!/usr/bin/env bash

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

# Mouse
echo "Mouse: Scroll direction set to unnatural"
defaults write -g com.apple.swipescrolldirection -bool false

# 内置触控板和 Apple 蓝牙触控板使用不同的偏好域，保持两者手势一致。
for trackpad_domain in \
    com.apple.AppleMultitouchTrackpad \
    com.apple.driver.AppleBluetoothMultitouch.trackpad; do
    # 关闭单指轻点点击，需要按下触控板才算点击。
    defaults write "$trackpad_domain" Clicking -bool false
    # 开启双指辅助点按（右键）。
    defaults write "$trackpad_domain" TrackpadRightClick -bool true
    # 不使用触控板角落作为右键点击区域。
    defaults write "$trackpad_domain" TrackpadCornerSecondaryClick -int 0
    # 关闭三指拖移。
    defaults write "$trackpad_domain" TrackpadThreeFingerDrag -bool false
    # 关闭轻点后拖移。
    defaults write "$trackpad_domain" Dragging -bool false
    # 关闭拖移锁定，松手后不会继续拖移。
    defaults write "$trackpad_domain" DragLock -bool false
done
# 开启用力点按。
defaults write NSGlobalDomain com.apple.trackpad.forceClick -bool true

# 关闭按最近使用情况自动重排桌面空间，保持 Space 顺序固定。
echo "Mission Control: Keep Spaces in a fixed order"
defaults write com.apple.dock mru-spaces -bool false
# 鼠标离开时自动隐藏 Dock，给窗口留出更多空间。
defaults write com.apple.dock autohide -bool true

# Finder 显示所有文件的扩展名，例如 .sh、.json。
echo "Finder: Show all file extensions and the path bar"
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
# Finder 窗口底部显示当前文件夹的完整路径栏。
defaults write com.apple.finder ShowPathbar -bool true
# 没有单独指定视图的文件夹默认使用列表视图。
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# remap Caps Lock to Option on the built-in keyboard (takes effect after re-login)
echo "Remap: Caps Lock to Ooption"
python3 "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/remap_keys.py"
