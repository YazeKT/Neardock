# Development

Use Flutter 3.41.9 from .fvmrc and Rust 1.97.1 from rust-toolchain.toml. On Windows,
install Visual Studio 2022 C++ desktop build tools and Windows SDK. Android needs
JDK 17 and the SDK/build tools specified by the retained Gradle configuration.

```text
fvm install
fvm flutter pub get
cd app
fvm dart run build_runner build
fvm dart run slang
fvm flutter analyze
fvm flutter test
cd ../packages/localsend_isolates
fvm flutter test
cd ../core
cargo test --features full
cargo clippy --features full --all-targets
```

The checked-in Flutter submodule is an equivalent pinned SDK for bootstrap when
FVM is not yet available. Enable Git core.longpaths for its Windows checkout.
Generated Dart uses 150-column formatting. Do not reformat unrelated generated
files. Use `cargo check --package rust_lib_localsend_app` at the repository root.

Before a Windows build, package the MSIX helper using the Windows SDK tools in
support/scripts/compile_windows_msix_helper.ps1. Then run, from app/:
`fvm flutter build windows --release`.
Package using support/neardock/package_windows.ps1. ARM64 uses an ARM64 Windows
runner (Flutter selects the host architecture). No CLI or other platform build is required.

For Android signing, follow RELEASING.md. GitHub APK builds use the upstream FOSS
stripping script so donations use the existing external upstream donation links.
Run that script only in a disposable build checkout; it modifies source files.

Regenerate logo assets with `python support/neardock/generate_assets.py` (Pillow).
Run `python support/neardock/check_release.py`. Preview the website with
`python -m http.server 4173 --directory website`.
