# Device identity and trust

Neardock remembers nearby device properties locally: the certificate fingerprint, latest advertised alias,
model/type, first and last discovery times, and up to 16 recently observed addresses. Rediscovery updates
one record per fingerprint, including after an IP or random-name change. Two different certificates are
kept distinct even when they advertise the same name or address. Reinstalling/resetting a device identity
requires new consent; silently merging those identities would make impersonation possible.

The first encrypted incoming request offers **Trust & accept**, **Review this transfer**, or **Decline**.
Only explicitly trusted devices with the exact certificate fingerprint verified by the existing encrypted
server bypass repeated consent. Trust applies to both files and text. PIN verification, storage permission,
folder handling, and existing transfer checks still apply. Settings / Devices lets you revoke trust or forget
a saved device. Encryption-off requests cannot use saved trust. Existing user-selected Quick Save modes
remain separate policies. No PIN or clipboard content is stored in device metadata.

IP addresses are dynamic connection metadata, never authentication. The protocol does not advertise a
remote Wi-Fi network name; Neardock does not request Android location permission to guess it. A shared
LAN can be Wi-Fi, Ethernet, or a phone hotspot; using a hotspot need not consume mobile data for local
transfers. Internet/WebRTC connectivity is a separate existing upstream facility and is not enabled merely
by saving a device. SSIDs and addresses cannot safely identify a person or prove trust.

Duplicate prepare-session events do not stack receive pages. Cancellation dismisses the current connection
consent dialog; stale consent cannot accept a replacement session. Trusted completed transfers do not show
the extra open-file confirmation dialog. Untrusted text is retained only after the user accepts, rather than
being saved while a request is still awaiting consent.

Provider tests verify rediscovery/address merge, identical aliases with different keys, encrypted verified
identity requirements, restart persistence, revocation, forget, malformed metadata, and queued-write safety.
Physical Windows/Android receive, cancellation, PIN, permissions and interoperability checks remain necessary.
