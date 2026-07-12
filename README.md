# Master PDF Editor Patch

Bypasses license validation for **Master PDF Editor 5.9.98** using inline hooking via [tinyhook](https://github.com/Antibioticss/tinyhook).

Supports both **Apple Silicon (arm64)** and **Intel (x86_64)** architectures.

## How it works

The dylib hooks `MainWindow::ValidateLicense` to force license flags, then calls `QDocTab::SetRegProgram` to complete activation.

## Build

```sh
git clone --recurse-submodules https://github.com/NohamR/MasterPDFEditor-patch.git
cd MasterPDFEditor-patch
make
```

Output: `MasterPDFEditor.dylib`

## Usage

To use the dylib, you have two options:

**Option 1 — DYLD_INSERT_LIBRARIES** (requires SIP to be turned off; refer to [Apple's documentation](https://developer.apple.com/documentation/security/disabling-and-enabling-system-integrity-protection)):

```sh
DYLD_INSERT_LIBRARIES=/path/to/MasterPDFEditor.dylib '/Applications/Master PDF Editor.app/Contents/MacOS/Master PDF Editor'
```

**Option 2 — Permanent injection** (uses [optool](https://github.com/alexzielenski/optool) to inject the dylib into the app bundle):

```sh
./inject.sh /path/to/MasterPDFEditor.dylib '/Applications/Master PDF Editor.app'
```

## Analysis

Full reverse engineering write-up: [noham.dev](https://noh.am/en/posts/master-pdf-editor-patch-analysis/)