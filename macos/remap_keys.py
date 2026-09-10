#!/usr/bin/env python3
"""Remap Caps Lock to Option via macOS ByHost modifier mapping.

Auto-detects the built-in keyboard (Apple Silicon reports vendor/product
0/0; Intel internal keyboards have real IDs) and adds the mapping entry to
~/Library/Preferences/ByHost/.GlobalPreferences.<uuid>.plist — the same
store System Settings writes to. Idempotent: existing entries are kept.

Usage:
    remap_keys.py [VENDOR-PRODUCT]...

Without arguments, applies to the built-in keyboard. Extra arguments add
the same mapping for specific keyboards, e.g. `remap_keys.py 1130-180`.

Takes effect after logging out and back in (or a restart).
"""

import glob
import os
import plistlib
import re
import subprocess
import sys

CAPS_LOCK = 30064771129  # USB HID usage 0x700000039
OPTION = 30064771298     # USB HID usage 0x7000000E2 (left option)


def builtin_keyboard_id():
    out = subprocess.run(["hidutil", "list"], capture_output=True, text=True).stdout
    for line in out.splitlines():
        if "KeyboardEventDriver" in line and line.rstrip().endswith("1"):
            m = re.match(r"(0x[0-9a-fA-F]+)\s+(0x[0-9a-fA-F]+)", line)
            if m:
                return int(m.group(1), 16), int(m.group(2), 16)
    return 0, 0  # Apple Silicon fallback


def byhost_plist_path():
    paths = glob.glob(os.path.expanduser(
        "~/Library/Preferences/ByHost/.GlobalPreferences.*.plist"))
    if not paths:
        sys.exit("ByHost GlobalPreferences plist not found")
    return paths[0]


def main():
    devices = sys.argv[1:]
    if not devices:
        vid, pid = builtin_keyboard_id()
        devices = [f"{vid}-{pid}"]

    path = byhost_plist_path()
    with open(path, "rb") as f:
        plist = plistlib.load(f)

    for device in devices:
        key = f"com.apple.keyboard.modifiermapping.{device}-0"
        mapping = plist.setdefault(key, [])
        if any(e.get("HIDKeyboardModifierMappingSrc") == CAPS_LOCK for e in mapping):
            print(f"{device}: Caps Lock -> Option already present, skipped")
            continue
        mapping.append({
            "HIDKeyboardModifierMappingSrc": CAPS_LOCK,
            "HIDKeyboardModifierMappingDst": OPTION,
        })
        print(f"{device}: added Caps Lock -> Option")

    with open(path, "wb") as f:
        plistlib.dump(plist, f)
    subprocess.run(["killall", "cfprefsd"], capture_output=True)
    print("Log out and back in (or restart) for the mapping to take effect.")


if __name__ == "__main__":
    main()
