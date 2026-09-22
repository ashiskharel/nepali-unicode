#!/usr/bin/env python3
"""Check phonetic Nepali against the m17n engine.

Each case is typed as keysyms, then a space, which commits the preedit.
The expected Devanagari is what must be committed before that space.
"""

from __future__ import annotations

import shutil
import subprocess
import sys

CASES = [
    ("ka", "क"),
    ("kha", "ख"),
    ("namaste", "नमस्ते"),
    ("kaa", "का"),
    ("kA", "का"),
    ("ki", "कि"),
    ("kii", "की"),
    ("kee", "की"),
    ("ku", "कु"),
    ("kuu", "कू"),
    ("ke", "के"),
    ("kai", "कै"),
    ("ko", "को"),
    ("kau", "कौ"),
    ("a", "अ"),
    ("aa", "आ"),
    ("nepaal", "नेपाल"),
    ("ksha", "क्ष"),
    ("kshaa", "क्षा"),
    ("gya", "ज्ञ"),
    ("tra", "त्र"),
    ("ram", "रम"),
    ("raam", "राम"),
    ("OM", "ॐ"),
    ("0123456789", "०१२३४५६७८९"),
    ("kaM", "कं"),
    ("kaH", "कः"),
    ("ka*", "कँ"),
    ("Tha", "ठ"),
    ("Ta", "ट"),
    ("Da", "ड"),
    ("Dha", "ढ"),
    ("Na", "ण"),
    ("sha", "श"),
    ("Sha", "ष"),
    ("chha", "छ"),
    ("cha", "च"),
    ("gha", "घ"),
    ("nga", "ङ"),
    ("k/", "क्"),
    ("Ri", "ऋ"),
    ("kRi", "कृ"),
]


def keys_for(text: str) -> list[str]:
    out = []
    for ch in text:
        if ch == " ":
            out.append(" ")
        elif ch == "\\":
            out.append("\\")
        else:
            out.append(ch)
    out.append(" ")
    return out


def run_case(latin: str, expected: str) -> str | None:
    cmd = [
        "m17n-input-test",
        "--language",
        "ne",
        "--name",
        "phonetic",
        "--commit",
        expected + " ",
    ]
    for key in keys_for(latin):
        cmd.extend(["-k", key])
    result = subprocess.run(cmd, text=True, capture_output=True)
    if result.returncode == 0:
        return None
    detail = (result.stdout or result.stderr).strip()
    return detail or f"exit {result.returncode}"


def main() -> int:
    if shutil.which("m17n-input-test") is None:
        print("m17n-input-test is not installed (package m17n-lib).", file=sys.stderr)
        return 1
    failed = 0
    for latin, expected in CASES:
        err = run_case(latin, expected)
        if err:
            failed += 1
            print(f"FAIL {latin!r} → {expected!r}")
            print(f"  {err}")
        else:
            print(f"ok   {latin!r} → {expected}")
    if failed:
        print(f"{failed} failed", file=sys.stderr)
        return 1
    print(f"{len(CASES)} passed")
    return 0


if __name__ == "__main__":
    sys.exit(main())
