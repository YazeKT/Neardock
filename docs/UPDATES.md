# Neardock updates

Neardock checks the public `YazeKT/Neardock` latest stable GitHub release on launch when enabled. The welcome flow discloses this request before the first check. Turn it off in Settings / Updates; manual checks remain available. Local sharing continues when offline or when GitHub is unavailable. Checks send ordinary HTTP request metadata to GitHub; no device identifier, messages, file names or known-device registry is sent.

Only published, non-prerelease `neardock-vMAJOR.MINOR.PATCH` releases are considered. The installed version is compared numerically. A missing repository or release is reported as unavailable; it is not treated as an update.

Updates require an explicit download confirmation. The architecture-specific asset must use the exact Neardock repository/tag/filename URL, have a GitHub SHA-256 digest and declared size, and match both after download. A failed check deletes that temporary download. The app does not silently install or override OS protections.

Windows x64 installed builds open the unsigned installer. Windows ARM64 and portable builds download a portable ZIP for manual replacement: close Neardock, replace app files and preserve settings.json. Android opens its system installer; Android may ask to allow installations from this source, and accepts an in-place update only with the same signing identity. Existing app data must not be cleared.

GitHub hashes detect corrupted downloads; they do not replace a code-signing certificate or defend against a compromised publishing account. Windows builds currently remain unsigned. Release publishing must retain the private Android signing key and include verified assets and SHA256SUMS.txt. Never include signing keys in source or release archives.

End-to-end updating from a newer public Neardock release remains pending until that release exists. Parser/repository/version rules are covered by local tests; compilation is not evidence of installer lifecycle testing.

Sources: [GitHub release API](https://docs.github.com/en/rest/releases/releases), [release asset digests](https://github.blog/changelog/2025-06-03-releases-now-expose-digests-for-release-assets/), [Android alternative distribution](https://developer.android.com/distribute/marketing-tools/alternative-distribution).
