# Neardock interface review

The interface follows the ink-and-orange Windows and Android sheets in
`design/screens/`. It is a working Flutter interface, not an embedded mockup.
The LocalSend Rust core and isolate implementation remain unchanged.

## Navigation and settings

Send, Receive, Chat, Clipboard, and Settings have separate destinations.
Windows uses a sidebar; Android uses bottom navigation. File drops and Android
share intents continue to enter Send. The existing Receive startup destination
is retained. The N logo remains upright and stationary.

Settings groups existing options into Appearance, Transfers, Devices,
Chat & Clipboard, Privacy, Advanced, and About & Licences. Existing stored
choices are preserved. New installations, and installations without a saved
theme choice, default to dark. Existing advanced options remain behind the
Advanced settings toggle.

## Text conversations

Chat sends ordinary LocalSend UTF-8 text transfers. It does not introduce a
chat protocol, accounts, cloud storage, read receipts, or background message
delivery. Existing receive confirmation and session handling still apply.
Completed means the transfer session completed; it is not a read receipt.

Incoming text appears in the shared conversation inbox and Clipboard's received
text list. The sender's Chat/Clipboard tab is not transmitted. Conversations
use device fingerprints, not IP addresses or names, to group devices.

Conversation history is saved locally by default. Turn it off or clear it in
Chat & Clipboard settings. Disabling history removes persisted conversation
messages while keeping current-session text until exit. New text is not also
saved in the legacy file-history store. Older file-history entries are left
intact and may be cleared separately through the existing history controls.
Failed, rejected, and interrupted outgoing text remains available for retry.
Unsent drafts are held in memory and are not restored after app exit.

Clipboard access is manual: Paste reads the clipboard, and Copy writes selected
received text. There is no clipboard watcher or automatic clipboard replacement.
These text views target nearby devices on the local network; existing Send
modes and link-sharing capabilities remain available in Send and Receive.

## Owner review checklist

The refinement adds a welcome flow, one-time encrypted device trust, compact inline Settings, device properties, logs and GitHub updates. For the first incoming encrypted request choose Trust & accept only for a device you control. Verify a second request does not ask again, then revoke trust and verify approval returns. Test cancellation while the first trust prompt is open. Distinct certificate identities are deliberately not merged by IP or alias. Review the duplicate-name case with both devices restarted before declaring it resolved.

Settings sections start collapsed and open in place. Test the welcome update opt-out, the About logo, device properties and copied diagnostics. Update installation remains pending until a newer public release exists.

- Check the main screens, all Settings categories, About, and the stationary N.
- Send files in both directions between Windows and Android; compare hashes.
- Check multiple files, folders, selection removal, cancellation, rejection,
  receive PIN, destination choice, permissions, and interruption handling.
- Send and receive text with both Neardock and LocalSend. Close incoming text
  requests and confirm the conversation appears in Chat and Clipboard.
- Check draft preservation when switching tabs; failed text should remain.
- Check Paste and Copy explicitly; merely opening Clipboard must not access it.
- Relaunch to check conversation persistence. Check history off and clear-all.
- Check light, dark, system and custom colours, enlarged text, narrow Windows
  layouts, Android back navigation, keyboard visibility, tray and share intents.
- Owner review cleared publication on 3 October 2026; keep detailed untested cases recorded separately.

Build results and outstanding hardware checks are recorded in VERIFICATION.md.
