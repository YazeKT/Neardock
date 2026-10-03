# Signing and releases

## Android signing identity

Create a dedicated release keystore outside the repository using JDK keytool,
alias neardock, RSA 3072, validity 10000 days. Use a strong random password.
Back up the keystore and password in separate secure locations. Losing the key
prevents compatible APK updates. Never commit either item or print them in logs.

Local app/android/key.properties (ignored) contains storeFile (absolute path),
storePassword, keyPassword and keyAlias=neardock. Windows paths must use forward
slashes. GitHub Actions secrets are NEARDOCK_ANDROID_KEYSTORE (base64 keystore)
and NEARDOCK_ANDROID_PASSWORD. Set them through stdin/file-based gh secret set,
without embedding values in shell commands. Confirm release APK signatures using
apksigner verify --print-certs and retain the public certificate fingerprint.

## Build and publish

1. Run existing checks and support/neardock/check_release.py.
2. Dispatch Neardock Windows and Android builds from the reviewed commit.
3. Download artifacts, verify archive content, package metadata and signatures.
4. Perform available acceptance checks; update docs/VERIFICATION.md honestly.
5. Calculate SHA-256 checksums and produce SHA256SUMS.txt.
6. Tag the tested commit neardock-v1.0.0 and create a draft GitHub release with
   matching assets and release notes. Do not upload debug-signed Android APKs.
7. Verify remotely downloaded assets against local hashes before publishing.
8. Update website/releases.json with only published artifact URLs and checksums;
   record buildVerified and deviceTested independently. Deploy and check Pages.

Windows signing is not configured. EXEs, DLLs and installers must be described as
unsigned. The share helper also lacks a trusted publisher signature; its native
Share integration remains pending verification. No upstream signing services,
app-store identities, package-manager publication or excluded-platform releases
are configured. Pages deploys the website directory; private vulnerability
reporting should be enabled in GitHub repository settings.
