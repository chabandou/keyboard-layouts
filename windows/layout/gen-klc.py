"""Generate a Windows MSKLC layout (.klc) from the Linux XKB keymap.

Source of truth: linux/xkb/keymaps/cmk_ed_dh_wide_full.xkb (compiled with
model pc104awide, which keeps standard evdev keycodes, so every XKB key name
below sits on its usual physical position). Levels 1-4 become the Windows
shift states Base, Shift, AltGr, Shift+AltGr. XKB dead keys become Windows
dead keys whose tables follow Unicode composition (the same results the
XKB Compose file gives for the common Latin letters).

Usage: python gen-klc.py [path/to/keymap.xkb] [out.klc]
"""
import re
import sys
import unicodedata
from pathlib import Path

HERE = Path(__file__).resolve().parent
REPO = HERE.parent.parent
XKB = Path(sys.argv[1]) if len(sys.argv) > 1 else REPO / "linux/xkb/keymaps/cmk_ed_dh_wide_full.xkb"
OUT = Path(sys.argv[2]) if len(sys.argv) > 2 else HERE / "CmkDHW.klc"

KBD_NAME = "CmkDHW"  # 8.3 DLL name: CmkDHW.dll
KBD_DESC = "Colemak-DH Wide (eD, Linux mirror)"

# XKB key name -> PC/AT set 1 scancode (ANSI board; LSGT is the ISO extra key).
SCANCODES = {"TLDE": 0x29, "BKSL": 0x2B, "SPCE": 0x39, "LSGT": 0x56}
SCANCODES.update({f"AE{i:02d}": 0x01 + i for i in range(1, 13)})
SCANCODES.update({f"AD{i:02d}": 0x0F + i for i in range(1, 13)})
SCANCODES.update({f"AC{i:02d}": 0x1D + i for i in range(1, 12)})
SCANCODES.update({f"AB{i:02d}": 0x2B + i for i in range(1, 11)})

KEYSYMS = {
    "space": " ", "nobreakspace": " ", "exclam": "!", "at": "@", "numbersign": "#",
    "dollar": "$", "percent": "%", "asciicircum": "^", "ampersand": "&", "asterisk": "*",
    "parenleft": "(", "parenright": ")", "minus": "-", "underscore": "_", "equal": "=",
    "plus": "+", "bracketleft": "[", "bracketright": "]", "braceleft": "{", "braceright": "}",
    "semicolon": ";", "colon": ":", "apostrophe": "'", "quotedbl": '"', "grave": "`",
    "asciitilde": "~", "backslash": "\\", "bar": "|", "comma": ",", "less": "<",
    "period": ".", "greater": ">", "slash": "/", "question": "?",
    "exclamdown": "¡", "twosuperior": "²", "threesuperior": "³",
    "sterling": "£", "mu": "µ", "partialderivative": "∂", "notsign": "¬",
    "infinity": "∞", "periodcentered": "·", "degree": "°", "notequal": "≠",
    "brokenbar": "¦", "guillemotleft": "«", "guillemotright": "»",
    "ae": "æ", "AE": "Æ", "ellipsis": "…", "questiondown": "¿",
    "oslash": "ø", "Oslash": "Ø",
    "KP_0": "0", "KP_1": "1", "KP_2": "2", "KP_3": "3", "KP_4": "4", "KP_5": "5",
    "KP_6": "6", "KP_7": "7", "KP_8": "8", "KP_9": "9", "KP_Divide": "/",
    "KP_Multiply": "*", "KP_Subtract": "-", "KP_Add": "+", "KP_Decimal": ".",
}

# dead keysym -> (Windows dead-key id char, combining mark or None, spacing form)
DEAD = {
    "dead_grave": ("`", "̀", "`"),
    "dead_tilde": ("~", "̃", "~"),
    "dead_circumflex": ("^", "̂", "^"),
    "dead_diaeresis": ("¨", "̈", "¨"),
    "dead_caron": ("ˇ", "̌", "ˇ"),
    "dead_breve": ("˘", "̆", "˘"),
    "dead_abovering": ("˚", "̊", "˚"),
    "dead_doubleacute": ("˝", "̋", "˝"),
    "dead_ogonek": ("˛", "̨", "˛"),
    "dead_belowdot": ("̣", "̣", "̣"),
    "dead_hook": ("̉", "̉", "̉"),
    "dead_horn": ("̛", "̛", "̛"),
    "dead_currency": ("¤", None, "¤"),
}
DEAD_NAMES = {
    "dead_grave": "GRAVE", "dead_tilde": "TILDE", "dead_circumflex": "CIRCUMFLEX",
    "dead_diaeresis": "DIAERESIS", "dead_caron": "CARON", "dead_breve": "BREVE",
    "dead_abovering": "RING ABOVE", "dead_doubleacute": "DOUBLE ACUTE",
    "dead_ogonek": "OGONEK", "dead_belowdot": "DOT BELOW", "dead_hook": "HOOK ABOVE",
    "dead_horn": "HORN", "dead_currency": "CURRENCY",
}
CURRENCY = {  # XKB Compose <dead_currency> table for letters
    "A": "₳", "a": "؋", "B": "฿", "b": "₿", "C": "₡", "c": "¢",
    "D": "₯", "d": "₫", "E": "₠", "e": "€", "F": "₣", "f": "ƒ",
    "G": "₲", "g": "₰", "h": "₴", "i": "﷼", "K": "₭", "k": "₺",
    "L": "₾", "l": "₤", "M": "ℳ", "m": "₥", "N": "₦", "n": "₦",
    "P": "₧", "p": "₽", "R": "₹", "r": "₨", "S": "$", "s": "₪",
    "T": "₮", "W": "₩", "w": "₩", "y": "¥", "Y": "¥",
}

VK_PUNCT = {
    "[": "OEM_4", "]": "OEM_6", "\\": "OEM_5", ";": "OEM_1", "'": "OEM_7", "`": "OEM_3",
    ",": "OEM_COMMA", ".": "OEM_PERIOD", "/": "OEM_2", "-": "OEM_MINUS", "=": "OEM_PLUS",
    " ": "SPACE",
}
CTRL_BY_VK = {"OEM_4": 0x1B, "OEM_6": 0x1D, "OEM_5": 0x1C, "OEM_MINUS": 0x1F,
              "6": 0x1E, "2": 0x00, "SPACE": 0x20}


def parse_symbols(text):
    sym = text[text.index("xkb_symbols"):]
    keys = {}
    for m in re.finditer(r"key <(\w+)>\s*\{\s*\[([^\]]*)\]\s*\}", sym):
        name, levels = m.group(1), [s.strip() for s in m.group(2).split(",")]
        if name in SCANCODES:
            keys[name] = levels
    return keys


def resolve(keysym):
    """Return (char, dead_keysym_or_None)."""
    if keysym in DEAD:
        return DEAD[keysym][0], keysym
    if keysym in KEYSYMS:
        return KEYSYMS[keysym], None
    if re.fullmatch(r"U[0-9A-Fa-f]{4,5}", keysym):
        return chr(int(keysym[1:], 16)), None
    if len(keysym) == 1:
        return keysym, None
    raise SystemExit(f"Unknown keysym: {keysym}")


def cell(ch, dead=False):
    if ch is None:
        return "-1"
    if not dead and re.fullmatch(r"[A-Za-z0-9]", ch):
        return ch
    return f"{ord(ch):04x}" + ("@" if dead else "")


def dead_table(dk):
    ident, comb, spacing = DEAD[dk]
    rows = [(" ", spacing), (" ", comb or spacing), (ident, spacing)]
    if dk == "dead_currency":
        rows += sorted(CURRENCY.items())
    else:
        for base in "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz":
            out = unicodedata.normalize("NFC", base + comb)
            if len(out) == 1 and out != base:
                rows.append((base, out))
    seen, uniq = set(), []
    for b, r in rows:
        if b not in seen:
            seen.add(b)
            uniq.append((b, r))
    return uniq


def main():
    keys = parse_symbols(XKB.read_text(encoding="utf-8"))
    missing = sorted(set(SCANCODES) - set(keys) - {"LSGT"})
    if missing:
        raise SystemExit(f"Keys missing from {XKB}: {missing}")

    lines, used_dead, used_vks = [], [], {}
    for name, sc in sorted(SCANCODES.items(), key=lambda kv: kv[1]):
        if name not in keys:
            continue
        lv = (keys[name] + [None] * 4)[:4]
        chars = [resolve(k) if k else (None, None) for k in lv]
        base = chars[0][0]
        if name == "LSGT":
            vk = "OEM_102"  # ISO extra key; keep its own VK so it can't shadow Z
        elif re.fullmatch(r"[a-z]", base):
            vk = base.upper()
        elif re.fullmatch(r"[0-9]", base):
            vk = base
        else:
            vk = VK_PUNCT[base]
        if vk in used_vks:
            raise SystemExit(f"VK {vk} used by both {used_vks[vk]} and {name}")
        used_vks[vk] = name
        shifted = chars[1][0]
        cap = 1 if base and shifted and base.isalpha() and shifted == base.upper() else 0
        ctrl = CTRL_BY_VK.get(vk)
        cols = [cell(chars[0][0], chars[0][1] is not None),
                cell(chars[1][0], chars[1][1] is not None),
                "-1" if ctrl is None else f"{ctrl:04x}",
                cell(chars[2][0], chars[2][1] is not None),
                cell(chars[3][0], chars[3][1] is not None)]
        for c, dk in chars:
            if dk and dk not in used_dead:
                used_dead.append(dk)
        names = ", ".join(unicodedata.name(c, f"U+{ord(c):04X}") if c else "<none>" for c, _ in chars)
        lines.append(f"{sc:02x}\t{vk}\t\t{cap}\t" + "\t".join(cols) + f"\t// {name}: {names}")

    out = [
        f'KBD\t{KBD_NAME}\t"{KBD_DESC}"', "",
        'COPYRIGHT\t"(c) chabandou"', "",
        'COMPANY\t"chabandou"', "",
        'LOCALENAME\t"en-US"', "",
        'LOCALEID\t"00000409"', "",
        "VERSION\t1.0", "",
        "SHIFTSTATE", "",
        "0\t//Column 4", "1\t//Column 5 : Shft", "2\t//Column 6 :       Ctrl",
        "6\t//Column 7 :       Ctrl Alt", "7\t//Column 8 : Shft  Ctrl Alt", "",
        "LAYOUT\t\t;an extra '@' at the end is a dead key", "",
        "//SC\tVK_\t\tCap\t0\t1\t2\t6\t7",
        "//--\t----\t\t----\t----\t----\t----\t----\t----", "",
        *lines, "", "",
    ]
    for dk in used_dead:
        out += [f"DEADKEY\t{ord(DEAD[dk][0]):04x}", ""]
        out += [f"{ord(b):04x}\t{ord(r):04x}\t// {b!r} -> {r!r}" for b, r in dead_table(dk)]
        out.append("")
    out += ["", "KEYNAME", "",
            "01\tEsc", "0e\tBackspace", "0f\tTab", "1c\tEnter", "1d\tCtrl", "2a\tShift",
            '36\t"Right Shift"', '37\t"Num *"', "38\tAlt", "39\tSpace", '3a\t"Caps Lock"',
            *[f"{0x3a + i:02x}\tF{i}" for i in range(1, 11)],
            "45\tPause", '46\t"Scroll Lock"', "57\tF11", "58\tF12", "",
            "KEYNAME_EXT", "",
            '1c\t"Num Enter"', '1d\t"Right Ctrl"', '35\t"Num /"', '37\t"Prnt Scrn"',
            '38\t"Right Alt"', '45\t"Num Lock"', "46\tBreak", "47\tHome", "48\tUp",
            '49\t"Page Up"', "4b\tLeft", "4d\tRight", "4f\tEnd", "50\tDown",
            '51\t"Page Down"', "52\tInsert", "53\tDelete", '5b\t"Left Windows"',
            '5c\t"Right Windows"', "5d\tApplication", "",
            "KEYNAME_DEAD", ""]
    out += [f'{ord(DEAD[dk][0]):04x}\t"{DEAD_NAMES[dk]}"' for dk in used_dead]
    out += ["", "DESCRIPTIONS", "", f"0409\t{KBD_DESC}", "",
            "LANGUAGENAMES", "", "0409\tEnglish (United States)", "", "ENDKBD", ""]
    # MSKLC expects UTF-16LE with BOM and CRLF line endings.
    OUT.write_bytes(b"\xff\xfe" + "\r\n".join(out).encode("utf-16-le"))
    print(f"Wrote {OUT} ({len(lines)} keys, {len(used_dead)} dead keys)")


if __name__ == "__main__":
    main()
