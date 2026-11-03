#!/usr/bin/env bash
# Restore the saved CHERRY MX Board modifier mapping for the current user.
set -euo pipefail

if [[ "$(uname -s)" != Darwin ]]; then
    echo "This script requires macOS." >&2
    exit 1
fi

# Vendor 1130 (0x046a), product 180 (0x00b4), keyboard ID 0.
# Use currentHost so a new Mac gets its own ByHost preferences.
# Replace this keyboard's mapping atomically; repeated runs are idempotent.
if [[ "${1:-}" != --runtime-only ]]; then
defaults -currentHost write -g com.apple.keyboard.modifiermapping.1130-180-0 -array \
    '{ HIDKeyboardModifierMappingSrc = 30064771129; HIDKeyboardModifierMappingDst = 30064771298; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771298; HIDKeyboardModifierMappingDst = 30064771299; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771299; HIDKeyboardModifierMappingDst = 30064771129; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771302; HIDKeyboardModifierMappingDst = 30064771303; }' \
    '{ HIDKeyboardModifierMappingSrc = 30064771303; HIDKeyboardModifierMappingDst = 30064771302; }'
fi

# Runtime mappings disappear on disconnect. install_mxboard.sh installs a
# LaunchAgent to reapply them after reconnecting. Do not remap other keyboards.
hidutil property --matching '{"VendorID":1130,"ProductID":180}' --set '{"UserKeyMapping":[
    {"HIDKeyboardModifierMappingSrc":30064771129,"HIDKeyboardModifierMappingDst":30064771298},
    {"HIDKeyboardModifierMappingSrc":30064771298,"HIDKeyboardModifierMappingDst":30064771299},
    {"HIDKeyboardModifierMappingSrc":30064771299,"HIDKeyboardModifierMappingDst":30064771129},
    {"HIDKeyboardModifierMappingSrc":30064771302,"HIDKeyboardModifierMappingDst":30064771303},
    {"HIDKeyboardModifierMappingSrc":30064771303,"HIDKeyboardModifierMappingDst":30064771302}
]}'

if [[ "${1:-}" == --runtime-only ]]; then
    exit 0
fi

echo "MX Board mapping saved:"
echo "  Caps Lock -> left Option; left Alt -> left Command; left Win -> Caps Lock"
echo "  right Alt -> right Command; right Win -> right Option"
echo "Applied and saved. Run macos/install_mxboard.sh for automatic reconnect recovery."
