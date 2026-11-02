#!/usr/bin/env python3
"""Set the default iTerm2 profile's fullscreen mode, palette, and background."""
import datetime
import pathlib
import plistlib
import subprocess
import urllib.request

DOMAIN = "com.googlecode.iterm2"
raw = subprocess.check_output(["defaults", "export", DOMAIN, "-"])
prefs = plistlib.loads(raw)
profiles = prefs.get("New Bookmarks", [])
profile = next((p for p in profiles
                if p.get("Guid") == prefs.get("Default Bookmark Guid")), None)
if profile is None:
    raise SystemExit("Open iTerm2 once to create a default profile, then retry.")

presets = pathlib.Path("/Applications/iTerm.app/Contents/Resources/ColorPresets.plist")
palette = plistlib.loads(presets.read_bytes())["Tango Dark"]
backup = pathlib.Path.home() / "Library/Application Support/dotfiles/backups"
backup.mkdir(parents=True, exist_ok=True)
stamp = datetime.datetime.now().strftime("%Y%m%d-%H%M%S-%f")
(backup / f"iterm2-{stamp}.plist").write_bytes(raw)

profile["Use Separate Colors for Light and Dark Mode"] = False
profile["Transparency"] = 0.0
# WINDOW_TYPE_LION_FULL_SCREEN: macOS native fullscreen for new windows.
profile["Window Type"] = 4
image_url = "https://github.com/FateScript/dotfiles/releases/download/0.0.1/qifantian.png"
image_target = backup.parent / "iterm-background.png"
with urllib.request.urlopen(image_url, timeout=30) as response:
    image_data = response.read()
image_target.write_bytes(image_data)
profile["Background Image Location"] = str(image_target)
# ASPECT_FILL: preserve proportions, fill the window, and crop the overflow.
profile["Background Image Mode"] = 2
for key, value in palette.items():
    color = {k: float(v) for k, v in value.items()}
    color.update({"Color Space": "sRGB", "Alpha Component": 1.0})
    for suffix in ("", " (Light)", " (Dark)"):
        profile[key + suffix] = color

# Write only the profiles key, preserving unrelated application preferences.
subprocess.run(["defaults", "write", DOMAIN, "New Bookmarks", "-array",
                *(plistlib.dumps(p).decode() for p in profiles)], check=True)
print("Saved native fullscreen and Tango Dark with background image for profile:", profile["Name"])
print("Restart iTerm2 when convenient to reload the saved profile.")
