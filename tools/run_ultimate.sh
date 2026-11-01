#!/usr/bin/env bash
# Send NOT 1942 DX to the C64 Ultimate / Ultimate 64 over its REST API and start
# it (make ultimate). Nothing is copied to the Ultimate's
# storage: a PRG is DMA-loaded and RUN, a CRT is started as a cartridge, a D64
# is mounted from memory on drive A.
#
#   ULT_HOST      address of the Ultimate       (default 192.168.10.148)
#   ULT_FILE      file to send                  (default build/not1942dx.prg,
#                 the compressed release PRG; build/not1942dx-turbo.prg etc.
#                 for the turbo version, which only starts with the CPU
#                 running at 2x or more: the Ultimate's turbo setting, if
#                 it has one)
#                 a .prg is loaded and RUN (POST /v1/runners:run_prg);
#                 a .d64 is mounted on drive A (POST /v1/drives/a:mount) and the
#                 machine reset, then type LOAD"*",8 and RUN yourself (fast loader)
#                 a .crt is started as a cartridge (POST /v1/runners:run_crt)
#   ULT_PASSWORD  network password, if one is set on the Ultimate (X-Password)
#   ULT_DRY=1     print what would be done and do nothing
#
# Never run by the build.
set -euo pipefail

cd "$(dirname "$0")/.."

HOST="${ULT_HOST:-192.168.10.148}"
FILE="${ULT_FILE:-build/not1942dx.prg}"
AUTH=()
[[ -n "${ULT_PASSWORD:-}" ]] && AUTH=(-H "X-Password: $ULT_PASSWORD")

if [[ ! -f "$FILE" ]]; then
    echo "missing: $FILE (build first: make release, or make turbo)" >&2
    exit 1
fi

# POST a file (or nothing) and fail on an HTTP error or a non-empty "errors" list
call() {    # call METHOD PATH [FILE]
    local method="$1" path="$2" body="${3:-}"
    local args=(-sS -m 30 -X "$method" "${AUTH[@]+"${AUTH[@]}"}" -w '\n%{http_code}')
    [[ -n "$body" ]] && args+=(-H 'Content-Type: application/octet-stream' --data-binary "@$body")
    if [[ -n "${ULT_DRY:-}" ]]; then
        echo "would: curl -X $method http://$HOST$path${body:+ <$body}"
        return
    fi
    local out code
    out=$(curl "${args[@]}" "http://$HOST$path") || { echo "ultimate: $HOST does not answer" >&2; exit 1; }
    code="${out##*$'\n'}"
    out="${out%$'\n'*}"
    if [[ "$code" != 2* ]] || ! grep -q '"errors" *: *\[ *\]' <<<"$out"; then
        echo "ultimate: $method $path -> HTTP $code" >&2
        echo "$out" >&2
        exit 1
    fi
}

if [[ -n "${ULT_DRY:-}" ]]; then
    echo "ultimate: dry run, $HOST not contacted"
else
    info=$(curl -sS -m 5 "${AUTH[@]+"${AUTH[@]}"}" "http://$HOST/v1/info" 2>/dev/null) \
        || { echo "ultimate: $HOST does not answer" >&2; exit 1; }
    product=$(sed -n 's/.*"product" *: *"\([^"]*\)".*/\1/p' <<<"$info")
    firmware=$(sed -n 's/.*"firmware_version" *: *"\([^"]*\)".*/\1/p' <<<"$info")
    echo "ultimate: ${product:-?} firmware ${firmware:-?} at $HOST"
fi

case "$FILE" in
    *.prg)
        call POST /v1/runners:run_prg "$FILE"
        echo "ultimate: $FILE loaded and RUN"
        ;;
    *.crt)
        call POST /v1/runners:run_crt "$FILE"
        echo "ultimate: $FILE started as a cartridge"
        ;;
    *.d64)
        call POST "/v1/drives/a:mount?type=d64&mode=readonly" "$FILE"
        call PUT /v1/machine:reset
        echo "ultimate: $FILE mounted on drive A, machine reset: LOAD\"*\",8 then RUN"
        ;;
    *)
        echo "ultimate: $FILE is not a .prg, .crt or .d64" >&2
        exit 1
        ;;
esac
