# Nepali Unicode

Two Nepali keyboards that type real Devanagari (Unicode), not a Preeti font.

| Layout | How you type | What you get |
| --- | --- | --- |
| Phonetic | Latin, as the word sounds: `namaste`, `kha`, `nepaal` | `नमस्ते`, `ख`, `नेपाल` |
| Traditional | The standard Nepali typewriter positions | The same Unicode letters, one key each |

Hyprland stays on your US layout. fcitx5 does the switching, so the two methods do not fight the compositor.

## Install

Arch and Omarchy already ship fcitx5. The phonetic layout also needs the m17n engine:

```sh
sudo pacman -S fcitx5 fcitx5-gtk fcitx5-m17n m17n-db
```

Omarchy has fcitx5 and fcitx5-gtk already. Then, from this directory:

```sh
./install.sh                  # both layouts
./install.sh --phonetic       # Latin to Devanagari only
./install.sh --traditional    # typewriter only
```

The script copies files into your home directory and adds them next to the US keyboard in the fcitx5 profile. It does not need root, and running it again does not add a second copy. US stays the default.

Press Ctrl+Space to cycle US, traditional Nepali, and phonetic. That is fcitx's default trigger, and with the default settings it cycles methods instead of only toggling. On Omarchy the bar's keyboard widget follows Hyprland's layout, which stays US. The popup fcitx shows when you press Ctrl+Space names the method you just landed on.

Log out and back in if a program was already open and still types Latin. New terminals and Chromium pick the method up immediately after a switch.

## Phonetic

A consonant includes the inherent अ, so `ka` is `क` and `kha` is `ख`. A longer vowel replaces it: `kaa` or `kA` is `का`. The next consonant inserts a halant, which is why `namaste` is `नमस्ते` and `tra` is `त्र`.

Long आ is `aa`. `nepal` is `नेपल`. `nepaal` is `नेपाल`.

| Type | Result | Type | Result |
| --- | --- | --- | --- |
| `a` `aa` | अ आ | `i` `ii` / `ee` | इ ई |
| `u` `uu` / `oo` | उ ऊ | `e` `ai` | ए ऐ |
| `o` `au` | ओ औ | `Ri` | ऋ |
| `ka` `kha` `ga` `gha` `nga` | क ख ग घ ङ | `cha` `chha` `ja` `jha` `yna` | च छ ज झ ञ |
| `Ta` `Tha` `Da` `Dha` `Na` | ट ठ ड ढ ण | `ta` `tha` `da` `dha` `na` | त थ द ध न |
| `pa` `pha` / `fa` | प फ | `ba` `bha` `ma` | ब भ म |
| `ya` `ra` `la` `va` / `wa` | य र ल व | `sha` `Sha` `sa` `ha` | श ष स ह |
| `ksha` | क्ष | `gya` | ज्ञ |
| `M` `H` `*` | ं ः ँ | `0`–`9` | ०–९ |

`/` after a consonant forces the halant (`k/` is `क्`). `|` is ZWJ, `\` is ZWNJ. `.` is danda `।`, `..` is `॥`. `OM` is `ॐ`.

`gya` is the conjunct `ज्ञ`, not `ग्य`. Type `g/yaa` for `ग्या`.

Check the phonetic map with m17n, from this directory:

```sh
python3 tests/check_phonetic.py
```

## Traditional

`traditional/np` is the standard Nepali typewriter, derived from xkeyboard-config's `np` basic variant (see `LICENSE-xkb`). The installer puts it at `~/.config/xkb/symbols/np` and registers `keyboard-np` with fcitx5.

The number row is Nepali digits `१`–`०`. Shift-digit is the usual punctuation. The letter block is the typewriter: `q` is `ट`, `w` is `ौ`, and so on, matching the comments in `traditional/np`. Backslash is `ॐ`, shift-backslash is `ः`. The key right of `म` is danda `।`.

## License

Original files are MIT (`LICENSE`). The traditional symbols file keeps the xkeyboard-config terms in `LICENSE-xkb`.
