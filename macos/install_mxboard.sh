#!/usr/bin/env bash
# Install automatic MX Board mapping recovery for the current macOS user.
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
    echo "This script requires macOS." >&2
    exit 1
fi

source_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
support_dir="$HOME/Library/Application Support/dotfiles/mxboard"
agent_path="$HOME/Library/LaunchAgents/local.dotfiles.mxboard.plist"
agent_target="gui/$(id -u)/local.dotfiles.mxboard"

mkdir -p "$support_dir" "$(dirname "$agent_path")" "$HOME/Library/Logs/dotfiles"
# Keep working even if the repository is moved or removed.
install -m 755 "$source_dir/apply_mxboard.sh" "$support_dir/apply_mxboard.sh"
watcher_tmp="$(mktemp "$support_dir/watcher.XXXXXX")"
trap 'rm -f "$watcher_tmp"' EXIT
xcrun swiftc -O "$source_dir/watch_mxboard.swift" -o "$watcher_tmp"
chmod 755 "$watcher_tmp"
# Replace atomically, including when the previous watcher is running.
mv -f "$watcher_tmp" "$support_dir/watch_mxboard"

# plutil handles spaces and XML metacharacters in the user's home path.
agent_tmp="$(mktemp "$support_dir/agent.XXXXXX")"
trap 'rm -f "$agent_tmp"' EXIT
cat > "$agent_tmp" <<'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key><string>local.dotfiles.mxboard</string>
    <key>ProgramArguments</key>
    <array/>
    <key>RunAtLoad</key><true/>
    <key>KeepAlive</key><true/>
    <key>ThrottleInterval</key><integer>5</integer>
</dict>
</plist>
PLIST
# Build an empty array explicitly: some plutil versions insert at array indexes
# even with -replace, leaving placeholder strings in the argument list.
plutil -insert ProgramArguments.0 -string "$support_dir/watch_mxboard" "$agent_tmp"
plutil -insert ProgramArguments.1 -string "$support_dir/apply_mxboard.sh" "$agent_tmp"
plutil -insert StandardErrorPath -string "$HOME/Library/Logs/dotfiles/mxboard.log" "$agent_tmp"
plutil -lint "$agent_tmp"
install -m 644 "$agent_tmp" "$agent_path"

bash "$support_dir/apply_mxboard.sh"
if launchctl print "$agent_target" >/dev/null 2>&1; then
    launchctl bootout "$agent_target"
fi
launchctl bootstrap "gui/$(id -u)" "$agent_path"
echo "Installed: MX Board mappings are applied at login and on every device connection."
