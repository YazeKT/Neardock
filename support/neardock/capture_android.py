"""Capture a reviewed Neardock screen from an authorized Android device."""
from pathlib import Path
import os, subprocess, sys
root = Path(__file__).resolve().parents[2]
adb = Path(os.environ["LOCALAPPDATA"]) / "Android/Sdk/platform-tools/adb.exe"
state = subprocess.run([str(adb), "shell", "dumpsys", "activity", "activities"], capture_output=True, text=True, check=True).stdout
resumed = [line for line in state.splitlines() if "mResumedActivity" in line or "topResumedActivity" in line]
if not any("io.github.yazekt.neardock/" in line for line in resumed):
    raise SystemExit("Open the Neardock screen to capture first; other apps will not be captured.")
focus = subprocess.run([str(adb), "shell", "dumpsys", "window"], capture_output=True, text=True, check=True).stdout
focus_lines = [line for line in focus.splitlines() if "mCurrentFocus=" in line]
if not any("io.github.yazekt.neardock/" in line for line in focus_lines):
    raise SystemExit("Neardock must be the focused screen, with permission dialogs and the lock screen dismissed.")
name = sys.argv[1] if len(sys.argv) > 1 else "android-receive"
if name not in {"android-receive", "android-send", "android-settings"}:
    raise SystemExit("Choose android-receive, android-send or android-settings.")
destination = root / ".local/screenshots" / (name + ".png")
destination.parent.mkdir(parents=True, exist_ok=True)
data = subprocess.run([str(adb), "exec-out", "screencap", "-p"], capture_output=True, check=True).stdout
if not data.startswith(b"\x89PNG\r\n\x1a\n"):
    raise SystemExit("The device did not return a PNG screenshot.")
destination.write_bytes(data)
print("Saved local screenshot for privacy review:", destination)

