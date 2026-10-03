# Privacy

Neardock retains LocalSend v1.18.2's transfer core and existing file-sharing settings. Local-network
transfers do not require an account or an internet connection. Settings, device
identity, favourites, and transfer history are stored locally according to the
app's existing settings. Recipients receive the files and messages you select.

Local discovery communicates with devices on the network. The retained WebRTC
source is disabled in this build; Neardock does not currently enable remote
sharing through the upstream signalling or STUN services. Browser link sharing
uses the existing reachable local server. External support, update and donation
links contact their respective services.

The Neardock product website contains no analytics, cookies, external font
requests, or account system. GitHub hosts the site, source, and downloads and
may process request information under its own privacy policy.

Windows Neardock settings use %APPDATA%/Neardock/settings.json; portable builds
use settings.json beside the executable. Android uses its own app sandbox.
Existing LocalSend data is not imported. Deleting settings is separate from
deleting files you have received. See installation guidance before uninstalling.

## Chat and Clipboard

Text conversations use the existing text-transfer format. Messages are stored
locally in Neardock's settings by default and grouped by the device fingerprint.
There is no cloud conversation sync or read-receipt service. Chat & Clipboard
settings allow history to be disabled, individual conversations to be cleared,
and all conversation history to be cleared. Disabling history removes saved
conversation messages; current-session messages remain until exit. Unsent drafts
are not written to disk. Local history is not separately encrypted at rest and
is protected by the operating system's app-data access controls.

New text is stored in the conversation inbox rather than duplicated in file
history. Older receive-history text remains unchanged and may be removed using
the existing file-history controls. Clipboard content is read only when Paste
is pressed and replaced only when Copy is pressed. Neardock does not monitor
the system clipboard or automatically synchronise its contents.
## Remembered devices and updates

Neardock saves device certificate fingerprints, advertised names/model/type, recent local addresses, discovery times and your explicit trust choices locally. It does not obtain a remote device's Wi-Fi SSID or request location access to infer it. Revoke trust or forget a saved device in Settings / Devices. A different certificate is a new identity even if its name or IP matches.

Optional launch-time update checks contact GitHub's public Neardock release API. They do not upload your device registry, identifiers, file names or message content. The welcome flow and Settings / Updates let you turn these checks off. Download and installation require your action; the operating system keeps its normal installer protections. See docs/UPDATES.md.

The new Logs panel copies only permitted diagnostic event types, timestamps, request methods and status codes. It excludes raw message text, addresses, names, PINs, file paths and other raw log values from the copied report. No diagnostics are sent automatically.

