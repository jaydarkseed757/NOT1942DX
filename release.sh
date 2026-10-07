#!/usr/bin/env bash
# =============================================================================
# release.sh - build NOT 1942 DX from clean and pack a release archive
# =============================================================================
#
#   ./release.sh               build everything, check it, write dist/not1942dx-<version>.zip
#   ./release.sh 1.1           the same, naming the archive for version 1.1
#   ./release.sh --dirty       allow uncommitted changes (a test archive)
#   ./release.sh --publish     also create a GitHub release (tag v<version>)
#                              with the archive attached (needs gh, logged in)
#
# The version defaults to the one on the title screen (data/title.asm).
# The archive holds the standard build (.d64, .prg, .crt), the MiSTer turbo
# build (turbo/), README.md, LICENSE, BUILD.txt and SHA256SUMS.
# =============================================================================
set -euo pipefail

cd "$(dirname "$0")"

version=""
dirty=0
publish=0
for arg in "$@"; do
    case "$arg" in
        --dirty)   dirty=1 ;;
        --publish) publish=1 ;;
        -h|--help) sed -n '2,16p' "$0"; exit 0 ;;
        -*)        echo "release.sh: unknown option $arg" >&2; exit 2 ;;
        *)         version="$arg" ;;
    esac
done

die() { echo "release.sh: $*" >&2; exit 1; }

# --- tools ---
for tool in acme exomizer c1541 python3 zip shasum; do
    command -v "$tool" >/dev/null || die "$tool not found (see README.md, Building)"
done
python3 -c "import PIL" 2>/dev/null || die "Python's Pillow is missing (pip3 install pillow)"
[ "$publish" = 1 ] && { command -v gh >/dev/null || die "--publish needs the GitHub CLI (gh)"; }

# --- version: the title screen's "dx 1.0" unless given ---
if [ -z "$version" ]; then
    version=$(grep -o '!scr "dx [0-9][0-9.]*"' data/title.asm | tail -1 | grep -o '[0-9][0-9.]*') \
        || die "can't find the version in data/title.asm; pass it: ./release.sh 1.0"
fi

# --- a release is built from a commit ---
if [ -n "$(git status --porcelain)" ]; then
    [ "$dirty" = 1 ] || die "uncommitted changes (commit them, or use --dirty for a test archive)"
    echo "warning: building with uncommitted changes"
fi
commit=$(git rev-parse --short HEAD)
[ "$dirty" = 1 ] && [ -n "$(git status --porcelain)" ] && commit="$commit (modified)"

# --- build everything from clean ---
echo "== building NOT 1942 DX $version from $commit"
make clean >/dev/null
make release turbo

# --- check: each compressed program must unpack to its dev build byte for byte ---
tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
check_unpack() {
    exomizer desfx -q -o "$tmp/unpacked.prg" "$1" >/dev/null
    cmp -s "$tmp/unpacked.prg" "$2" || die "$1 doesn't unpack to $2"
    echo "ok: $1 unpacks to $2"
}
check_unpack build/not1942dx.prg       build/not1942dx-dev.prg
check_unpack build/not1942dx-turbo.prg build/not1942dx-turbo-dev.prg

# --- pack ---
name="not1942dx-$version"
stage="$tmp/$name"
mkdir -p "$stage/turbo" dist
cp build/not1942dx.d64 build/not1942dx.prg build/not1942dx.crt "$stage/"
cp build/not1942dx-turbo.d64 build/not1942dx-turbo.prg build/not1942dx-turbo.crt "$stage/turbo/"
cp README.md LICENSE "$stage/"
cat > "$stage/BUILD.txt" <<EOF
NOT 1942 DX $version by JDC
Built $(date -u +"%Y-%m-%d %H:%M UTC") from commit $commit

Standard version (a stock PAL C64):
  not1942dx.d64   disk image:  LOAD"NOT 1942 DX",8,1 then RUN
  not1942dx.prg   program file, for emulators
  not1942dx.crt   Magic Desk cartridge image

MiSTer turbo version (C64 core, Turbo mode C128 or Smart, 2x-4x):
  turbo/not1942dx-turbo.d64   LOAD"NOT 1942 DX T",8,1 then RUN
  turbo/not1942dx-turbo.prg
  turbo/not1942dx-turbo.crt
EOF
(cd "$stage" && shasum -a 256 *.d64 *.prg *.crt turbo/* > SHA256SUMS)

archive="dist/$name.zip"
rm -f "$archive"
(cd "$tmp" && zip -qr -X "$OLDPWD/$archive" "$name")
echo
echo "== $archive ($(du -h "$archive" | cut -f1 | tr -d ' '))"
unzip -l "$archive" | sed -n '4,$p' | sed '$d' | sed '$d'

# --- optionally publish it on GitHub ---
tag="v$version"
if [ "$publish" = 1 ]; then
    [ "$dirty" = 1 ] && die "won't publish a --dirty build"
    git ls-remote --exit-code --tags origin "refs/tags/$tag" >/dev/null 2>&1 \
        && die "tag $tag already exists on GitHub"
    gh release create "$tag" "$archive" --target "$(git rev-parse HEAD)" \
        --title "NOT 1942 DX $version" \
        --notes "NOT 1942 DX $version for the Commodore 64 (PAL), plus the MiSTer turbo version. See BUILD.txt in the archive for which file is which."
    echo "== published GitHub release $tag"
elif [ "$dirty" = 1 ]; then
    echo
    echo "A test archive: commit the changes, then ./release.sh --publish makes the real release."
else
    echo
    echo "To publish it as a GitHub release:"
    echo "  ./release.sh --publish        (or: gh release create $tag $archive)"
fi
