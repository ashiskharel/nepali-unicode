#!/bin/sh
# Install Nepali Unicode layouts into the user fcitx5 profile.
# No root. Does not touch /usr.
set -eu

root=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
phonetic=0
traditional=0

usage() {
  echo "Usage: $0 [--phonetic] [--traditional]" >&2
  echo "With no flags, both layouts are installed." >&2
}

while [ $# -gt 0 ]; do
  case $1 in
    --phonetic) phonetic=1 ;;
    --traditional) traditional=1 ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
  shift
done

if [ "$phonetic" -eq 0 ] && [ "$traditional" -eq 0 ]; then
  phonetic=1
  traditional=1
fi

if ! command -v fcitx5 >/dev/null 2>&1; then
  echo "fcitx5 is not installed. On Arch: sudo pacman -S fcitx5 fcitx5-gtk" >&2
  exit 1
fi

if [ "$phonetic" -eq 1 ] && ! command -v m17n-input-test >/dev/null 2>&1; then
  echo "Phonetic layout needs m17n. On Arch: sudo pacman -S fcitx5-m17n m17n-db" >&2
  exit 1
fi

# Stop fcitx before rewriting the profile. On exit it saves the group it
# has in memory, which would replace the file we just wrote.
restart_fcitx=0
if command -v systemctl >/dev/null 2>&1 && systemctl --user is-active --quiet omarchy-fcitx5.service 2>/dev/null; then
  systemctl --user stop omarchy-fcitx5.service
  restart_fcitx=1
elif command -v fcitx5-remote >/dev/null 2>&1 && fcitx5-remote --check >/dev/null 2>&1; then
  fcitx5-remote -e >/dev/null 2>&1 || true
  echo "Stopped fcitx5 so it would not overwrite the profile. Start it again after this script." >&2
fi

profile=${XDG_CONFIG_HOME:-$HOME/.config}/fcitx5/profile
mkdir -p "$(dirname -- "$profile")"

if [ ! -f "$profile" ]; then
  cat >"$profile" <<'EOF'
[Groups/0]
# Group Name
Name=Default
# Layout
Default Layout=us
# Default Input Method
DefaultIM=keyboard-us

[Groups/0/Items/0]
# Name
Name=keyboard-us
# Layout
# Layout=

[GroupOrder]
0=Default
EOF
fi

add_im() {
  im=$1
  if grep -q "^Name=${im}$" "$profile"; then
    return 0
  fi
  last=$(grep -o '^\[Groups/0/Items/[0-9][0-9]*\]' "$profile" | sed 's/.*Items\///; s/\]$//' | sort -n | tail -n 1)
  if [ -z "$last" ]; then
    next=0
  else
    next=$((last + 1))
  fi
  tmp=$(mktemp)
  awk -v idx="$next" -v name="$im" '
    /^\[GroupOrder\]/ && !inserted {
      print "[Groups/0/Items/" idx "]"
      print "# Name"
      print "Name=" name
      print "# Layout"
      print "# Layout="
      print ""
      inserted = 1
    }
    { print }
    END {
      if (!inserted) {
        print ""
        print "[Groups/0/Items/" idx "]"
        print "# Name"
        print "Name=" name
        print "# Layout"
        print "# Layout="
      }
    }
  ' "$profile" >"$tmp"
  mv "$tmp" "$profile"
}

if [ "$traditional" -eq 1 ]; then
  dest=${XDG_CONFIG_HOME:-$HOME/.config}/xkb/symbols
  mkdir -p "$dest"
  cp "$root/traditional/np" "$dest/np"
  add_im keyboard-np
fi

if [ "$phonetic" -eq 1 ]; then
  mkdir -p "$HOME/.m17n.d"
  cp "$root/phonetic/ne-phonetic.mim" "$HOME/.m17n.d/ne-phonetic.mim"
  add_im m17n_ne_phonetic
fi

# US stays the method you land on. Re-running the installer puts it back.
tmp=$(mktemp)
awk '
  /^DefaultIM=/ { print "DefaultIM=keyboard-us"; next }
  { print }
' "$profile" >"$tmp"
mv "$tmp" "$profile"
chmod 600 "$profile"

if [ "$restart_fcitx" -eq 1 ]; then
  systemctl --user start omarchy-fcitx5.service
  i=0
  while [ "$i" -lt 20 ]; do
    if fcitx5-remote --check >/dev/null 2>&1; then
      fcitx5-remote -s keyboard-us >/dev/null 2>&1 || true
      break
    fi
    i=$((i + 1))
    sleep 0.2
  done
fi

echo "Installed into $profile"
echo "Cycle methods with Ctrl+Space. US stays the default until you switch."
echo "US stays the default until you switch."
