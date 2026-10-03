# Architecture

Neardock retains the Flutter UI, Refena state management, Dart isolate boundary,
flutter_rust_bridge plugin and Rust LocalSend core from the pinned release.
app/ owns UI, settings and native Windows/Android integration.
packages/localsend_isolates/ connects background isolates to packages/core/.
The Rust core owns discovery, HTTP transfers, cryptography and optional WebRTC.

Protocol paths, network defaults, fingerprints, encryption, cancellation, transfer
decisions and storage schema are preserved. Native Android channel names change
on both sides to match the product identity. Windows settings paths, registry
entries, SendTo shortcut and MSIX identity are independent of LocalSend.
The browser transfer pages carry Neardock branding without changing their logic.

Future features and UI improvements should use existing app/core boundaries and
receive their own compatibility tests. The marketing website is separate static
content and never handles user transfer files.

## Neardock presentation and text inbox

The Flutter shell has five destinations, a shared Neardock theme, and grouped
settings. Existing file-transfer providers remain the source of session state.
Chat and Clipboard share an app-layer conversation provider; plain text still
uses the existing transfer format. Conversation persistence has separate
`nd_conversation_*` keys, leaving the legacy settings and file-history schema
unchanged. A device fingerprint identifies a conversation. No Rust core,
isolate event format, or protocol extension is required.
