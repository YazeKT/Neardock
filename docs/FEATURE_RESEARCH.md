# Neardock feature research

Research reviewed 3 October 2026. These ten additions are recommendations, not release promises. They complement the requested trust, onboarding, logs, settings and updater work rather than counting those fixes as new features.

## What the backend can do today

The pinned source contains Rust WebRTC support and an Axum signalling server, but `app/lib/provider/network/webrtc/signaling_provider.dart` explicitly sets `webRTCEnabled = false`; `app/lib/config/init.dart` guards signalling startup with that flag. Neardock currently shares over reachable local networks. Wi-Fi, Ethernet connected to the same LAN, and a phone hotspot can provide that network; internet access is unnecessary for ordinary LAN transfers. A hotspot is a local connection, not a mobile-data transfer between distant devices. Some hotspots isolate clients, so discovery and direct-IP fallback need physical testing.

Internet/mobile-data sharing across separate networks is **not enabled**. A future implementation needs authenticated peer pairing, a Neardock-operated WSS signalling service, ICE/STUN configuration, TURN relay coverage for restrictive NATs, abuse limits, deployment monitoring, transport tests, consent and metered-data controls. GitHub Pages only hosts static website files; it cannot run the Axum service or TURN relay. Do not merely flip the experimental flag: the retained code has a transient key TODO and hardcoded upstream endpoints. Preserve ordinary LocalSend-compatible transfers alongside any negotiated Neardock-only extension.

## Evidence and direction

Current primary-source products point towards continuity between personal devices, intentional pairing, recovery from interrupted transfers and explicit ownership of data. This is a synthesis of their documented capabilities, not a measured ranking of 2026 market share or a claim that every item is a new trend.

- [PairDrop README](https://github.com/schlagmichdoch/PairDrop/blob/master/README.md): persistent pairing, temporary rooms, QR connection, previews, share-menu entry points and internet transfers with TURN. Relevant to connection friction and later remote sharing.
- [KDE Connect](https://kdeconnect.kde.org/) and its [official desktop README](https://github.com/KDE/kdeconnect-kde/blob/master/README.md): personal-device continuity through files, links and clipboard actions. Relevant to useful shortcuts without turning Neardock into a remote-control suite.
- [Syncthing block exchange protocol](https://docs.syncthing.net/specs/bep-v1.html): block hashes and requests for missing data. Its [versioning documentation](https://docs.syncthing.net/users/versioning.html) covers protecting replaced/deleted files. Relevant as engineering examples, not compatible drop-in protocol implementations.
- [Android clipboard privacy](https://developer.android.com/about/versions/10/privacy/changes#clipboard-data): Android 10+ restricts background clipboard reads to the focused app or default input method. Continuous invisible clipboard syncing is therefore unsuitable as a cross-platform promise.
- [Android Storage Access Framework](https://developer.android.com/training/data-storage/shared/documents-files): user-selected document access is the basis for safe Android folder destinations.

## Ten recommended additions

| Priority | Addition | Useful result | Windows + Android approach and boundary |
|---|---|---|---|
| 1 | Transfer queue with explicit retry | Send several batches without losing the next batch when one fails. | Shared queue model and per-device status; preserve permissions and revalidate file access on retry. Existing protocol can retry complete files; do not call it resume. |
| 2 | Transfer integrity report | Know which files arrived intact, with clear success/failure and exportable evidence. | Streaming SHA-256 and byte counts; sender/receiver comparison needs a negotiated extension or explicit comparison, not an invented guarantee. Keep hashes out of default public logs. |
| 3 | Saved destination rules | Photos to Pictures, documents to Documents, chosen separately per trusted device. | Explicit rules and preview; Windows writable paths, Android persisted SAF permissions. No silent overwrite or access outside approved destinations. |
| 4 | Searchable activity timeline | Find a received file, chat message or copied snippet in one place. | Local indexed metadata with filters and retention; open actual file only if still present. Respect disabled text history and deletion everywhere. |
| 5 | Pinned text snippets | Reuse an address, note or command between personal devices. | User-pinned local text, explicit Send/Copy, optional expiry and sensitive-content warnings; no background clipboard read requirement. |
| 6 | One-action share shortcuts | Send the selected item from another app to a chosen trusted device. | Android share targets/shortcut intents and Windows context/share entry points; confirmation and destination review remain available. Respect OS background limits. |
| 7 | Send-to-self collections | Keep a named batch of files and notes together, such as a trip or project handoff. | Shared collection UI and manifest alongside ordinary payloads; no cloud account. Preserve loose-file compatibility with LocalSend recipients. |
| 8 | Connection health assistant | Explain why a device is missing rather than showing an endless scan. | Local diagnostics for server/port, route, permissions and discovery; suggest manual address or hotspot steps. Export redacted diagnostic reports with consent. |
| 9 | Resumable large transfers | Continue a large file after Wi-Fi drops instead of starting again. | Later negotiated chunk/hash extension and temporary-file lifecycle on both platforms; quotas, expiry and exact source validation. This changes transport semantics and needs separate compatibility tests. |
| 10 | Optional remote personal-device sharing | Share to your own paired phone while away from the PC. | Later opt-in authenticated signalling/STUN/TURN mode, metered-data limits, relay transparency and revocable pairing. Operated services and cost controls required; no change to default offline LAN mode. |

Recommended delivery: queue, destinations, snippets and connection health first; activity and shortcuts next; integrity/collections after capability design; resume and remote sharing as separate architectural releases. Feature 2 starts with local per-file evidence before paired hash comparison.

## UI research applied to the website

The approved app identity remains the visual authority: ink, charcoal, orange, upright N and crisp corners. The website uses a real Windows app screenshot as the opening proof, a readable light content surface, a five-view screenshot switcher and a side-by-side Android capture. Typography uses self-hosted Space Grotesk (SIL OFL) with system body fallbacks; no external font requests. Navigation and download availability are explicit. No decorative glass, fabricated transfer speeds, customer counts, unsupported platforms or speculative-feature marketing. [Material typography guidance](https://m3.material.io/styles/typography/overview) informs readable hierarchy; this is not a claim of a particular design being the top 2026 trend.

Product captures are refreshed from the 1.0.0 local builds before publication. Build verification and physical-device checks are distinct; release links come only from the checked manifest.
