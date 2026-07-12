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

```sh
DYLD_INSERT_LIBRARIES=/path/to/MasterPDFEditor.dylib '/Applications/Master PDF Editor.app/Contents/MacOS/Master PDF Editor'
```

## Analysis

Full reverse engineering write-up: [noham.dev](https://noh.am/en/posts/master-pdf-editor-patch-analysis/)