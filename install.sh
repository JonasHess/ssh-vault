#!/bin/sh
# Bootstrap: download the dfm release for this machine, verify it, run it
# against this vault. Usage:  curl -fsSL <raw url of this file> | sh
set -eu
TOOL_REPO="JonasHess/dotfile-manager"
VAULT_URL="https://github.com/JonasHess/ssh-vault.git"
BIN_DIR="${DFM_BIN_DIR:-$HOME/.local/bin}"

os=$(uname -s | tr '[:upper:]' '[:lower:]')
arch=$(uname -m)
case "$arch" in
  x86_64|amd64) arch=amd64 ;;
  aarch64|arm64) arch=arm64 ;;
  armv7l|armv6l) arch=arm ;;
  *) echo "unsupported CPU: $arch" >&2; exit 1 ;;
esac
case "$os" in darwin|linux) ;; *) echo "unsupported OS: $os" >&2; exit 1 ;; esac

fetch() {
  if command -v curl >/dev/null 2>&1; then curl -fsSL "$1" -o "$2"
  elif command -v wget >/dev/null 2>&1; then wget -q "$1" -O "$2"
  else echo "need curl or wget" >&2; exit 1; fi
}

base="https://github.com/$TOOL_REPO/releases/latest/download"
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
fetch "$base/dfm-$os-$arch" "$tmp/dfm"
fetch "$base/SHA256SUMS" "$tmp/SHA256SUMS"
expected=$(grep " dfm-$os-$arch\$" "$tmp/SHA256SUMS" | cut -d' ' -f1)
if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$tmp/dfm" | cut -d' ' -f1)
else actual=$(shasum -a 256 "$tmp/dfm" | cut -d' ' -f1); fi
[ -n "$expected" ] && [ "$expected" = "$actual" ] || { echo "checksum mismatch for dfm-$os-$arch" >&2; exit 1; }

mkdir -p "$BIN_DIR"
install -m 0755 "$tmp/dfm" "$BIN_DIR/dfm"
echo "dfm installed to $BIN_DIR/dfm"
exec "$BIN_DIR/dfm" --vault "$VAULT_URL" "$@" </dev/tty
