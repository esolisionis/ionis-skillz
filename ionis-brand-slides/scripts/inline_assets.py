"""
inline_assets.py — make an Ionis HTML deck fully self-contained.

Replaces every external image reference in a deck.html file
(url("foo.png"), url("../assets/foo.svg"), etc.) with a base64
data URI so the file works standalone when shared by email or
moved between machines. Also inlines any <link rel="stylesheet">
references.

Usage:
    python inline_assets.py path/to/deck.html
        (overwrites in place; backup as deck.html.bak)
    python inline_assets.py path/to/deck.html -o deck.standalone.html
        (writes a new file, leaves original alone)

Assets are resolved relative to the deck.html file's folder.
Supported types: png, jpg, jpeg, gif, svg, webp, css.

Requires Python 3.7+ — no external dependencies.
"""
import argparse, base64, mimetypes, pathlib, re, shutil, sys

MIME_OVERRIDES = {
    ".svg": "image/svg+xml",
    ".webp": "image/webp",
    ".css": "text/css",
}


def encode_asset(path: pathlib.Path) -> str:
    ext = path.suffix.lower()
    mime = MIME_OVERRIDES.get(ext) or mimetypes.guess_type(str(path))[0] or "application/octet-stream"
    data = path.read_bytes()
    b64 = base64.b64encode(data).decode("ascii")
    return f"data:{mime};base64,{b64}"


def inline(deck_path: pathlib.Path, out_path: pathlib.Path):
    base = deck_path.parent
    html = deck_path.read_text(encoding="utf-8")

    # Inline <link rel="stylesheet" href="..."> by embedding the CSS body
    def link_repl(m):
        href = m.group(1)
        if href.startswith(("http://", "https://", "data:")):
            return m.group(0)
        css_path = (base / href).resolve()
        if not css_path.exists():
            print(f"  skip (not found): {href}", file=sys.stderr)
            return m.group(0)
        # Recursively resolve url(...) inside the CSS, relative to the CSS file's folder
        css_text = css_path.read_text(encoding="utf-8")
        css_text = inline_urls_in_text(css_text, css_path.parent)
        print(f"  inlined CSS: {href} ({len(css_text)} chars)")
        return f"<style>\n{css_text}\n</style>"

    html = re.sub(r'<link\s+[^>]*rel=["\']stylesheet["\'][^>]*href=["\']([^"\']+)["\'][^>]*/?>',
                  link_repl, html, flags=re.IGNORECASE)
    html = re.sub(r'<link\s+[^>]*href=["\']([^"\']+)["\'][^>]*rel=["\']stylesheet["\'][^>]*/?>',
                  link_repl, html, flags=re.IGNORECASE)

    # Inline url("...") references that point to local files
    html = inline_urls_in_text(html, base)

    out_path.write_text(html, encoding="utf-8")


URL_RE = re.compile(r'url\(["\']?([^"\')]+)["\']?\)')


def inline_urls_in_text(text: str, base: pathlib.Path) -> str:
    def repl(m):
        raw = m.group(1).strip()
        if raw.startswith(("data:", "http://", "https://", "#")):
            return m.group(0)
        asset = (base / raw).resolve()
        if not asset.exists():
            print(f"  skip (not found): {raw}", file=sys.stderr)
            return m.group(0)
        durl = encode_asset(asset)
        print(f"  inlined: {raw} -> {len(durl)} chars")
        return f'url("{durl}")'
    return URL_RE.sub(repl, text)


def main():
    p = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    p.add_argument("deck", type=pathlib.Path, help="Path to deck.html")
    p.add_argument("-o", "--output", type=pathlib.Path, default=None,
                   help="Output path (default: overwrite input with .bak backup)")
    args = p.parse_args()

    if not args.deck.exists():
        sys.exit(f"not found: {args.deck}")

    if args.output:
        out = args.output
    else:
        bak = args.deck.with_suffix(args.deck.suffix + ".bak")
        shutil.copy2(args.deck, bak)
        print(f"backup: {bak}")
        out = args.deck

    inline(args.deck, out)
    print(f"\nwrote: {out} ({out.stat().st_size:,} bytes)")


if __name__ == "__main__":
    main()
