#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
FLASH_ROOT="${FLASH_ROOT:-$ROOT/../flash}"
BUILD="$ROOT/.build"

cleanup_tmp_dir() {
  local dir="$1"
  if [ -n "$dir" ] && [ -d "$dir" ]; then
    rm -rf -- "$dir"
  fi
}

if [ ! -d "$FLASH_ROOT" ] || [ ! -x "$FLASH_ROOT/build.sh" ]; then
  echo "error: authoritative Flash source checkout is unavailable: $FLASH_ROOT" >&2
  exit 1
fi

# General compiler/runtime fixes live in Flash itself. Rebuild and run its
# canonical suite from the authoritative checkout before testing Flashy; never
# patch a consumer-side copy or silently use a stale flashc binary.
(cd "$FLASH_ROOT" && ./build.sh)

mkdir -p "$BUILD"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/foundation_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/foundation_test.flash" -o "$BUILD/foundation_test"
"$BUILD/foundation_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/layout_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/layout_test.flash" -o "$BUILD/layout_test"
"$BUILD/layout_test"

FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/inspector_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/inspector_test.flash" -o "$BUILD/inspector_test"
"$BUILD/inspector_test"

FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/geometry_safety_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/geometry_safety_test.flash" -o "$BUILD/geometry_safety_test"
"$BUILD/geometry_safety_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/text_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/text_test.flash" -o "$BUILD/text_test"
"$BUILD/text_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/keyboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/keyboard_test.flash" -o "$BUILD/keyboard_test"
"$BUILD/keyboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/x11_keyboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/x11_keyboard_test.flash" -o "$BUILD/x11_keyboard_test"
"$BUILD/x11_keyboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/x11_clipboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/x11_clipboard_test.flash" -o "$BUILD/x11_clipboard_test"
"$BUILD/x11_clipboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/app_clipboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/app_clipboard_test.flash" -o "$BUILD/app_clipboard_test"
"$BUILD/app_clipboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/wayland_keyboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/wayland_keyboard_test.flash" -o "$BUILD/wayland_keyboard_test"
"$BUILD/wayland_keyboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/wayland_clipboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/wayland_clipboard_test.flash" -o "$BUILD/wayland_clipboard_test"
"$BUILD/wayland_clipboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/wayland_native_clipboard_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/wayland_native_clipboard_test.flash" -o "$BUILD/wayland_native_clipboard_test"
"$BUILD/wayland_native_clipboard_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_protocol_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_protocol_test.flash" -o "$BUILD/automation_protocol_test"
"$BUILD/automation_protocol_test"

FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_endpoint_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_endpoint_test.flash" -o "$BUILD/automation_endpoint_test"
"$BUILD/automation_endpoint_test"

FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_app_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_app_test.flash" -o "$BUILD/automation_app_test"
"$BUILD/automation_app_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_external_server.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_external_server.flash" -o "$BUILD/automation_external_server"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_external_runner.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/automation_external_runner.flash" -o "$BUILD/automation_external_runner"
"$ROOT/tests/automation_external_gate.sh" \
    "$BUILD/automation_external_server" "$BUILD/automation_external_runner"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/assets_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/assets_test.flash" -o "$BUILD/assets_test"
"$BUILD/assets_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/graphics_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/graphics_test.flash" -o "$BUILD/graphics_test"
"$BUILD/graphics_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/effects_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/effects_test.flash" -o "$BUILD/effects_test"
"$BUILD/effects_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/platform_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/platform_test.flash" -o "$BUILD/platform_test"
"$BUILD/platform_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/app_test.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tests/app_test.flash" -o "$BUILD/app_test"
"$BUILD/app_test"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/examples/counter.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/examples/counter.flash" -o "$BUILD/counter"
"$BUILD/counter"
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tools/flashy.flash" --check
FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/tools/flashy.flash" -o "$BUILD/flashy"
"$BUILD/flashy" doctor

(
    cd "$ROOT/tests/cli_project"
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" check
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" check --emit-hot-manifest
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" check --hot --emit-hot-manifest
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" build
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" run
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" test
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" assets assets/icon.svg
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" assets ../../.build/assets_roundtrip.png
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" assets ../../.build/assets_animation.png
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" assets ../../.build/assets_animation_encoded.png
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" assets ../../.build/assets_baseline.jpg
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" assets ../../.build/assets_progressive.jpg
)

mkdir -p "$BUILD/init_project"
(
    cd "$BUILD/init_project"
    FLASH_HOME="$FLASH_ROOT" FLASHY_HOME="$ROOT" "$BUILD/flashy" init
    FLASH_HOME="$FLASH_ROOT" "$BUILD/flashy" check
)

(
    cd "$ROOT/tests/package_consumer"
    FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" app.flash --check
    FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" app.flash --hot --emit-hot-manifest -o "$BUILD/package_consumer_hot"
    FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" app.flash -o "$BUILD/package_consumer"
)
"$BUILD/package_consumer"

DISPLAY_VALUE="${DISPLAY:-}"
X11_DISPLAY_NUM=""
if [[ "$DISPLAY_VALUE" == *:* ]]; then
  X11_DISPLAY_NUM="${DISPLAY_VALUE##*:}"
  X11_DISPLAY_NUM="${X11_DISPLAY_NUM%%.*}"
fi
if [[ -n "$X11_DISPLAY_NUM" && -n "${XAUTHORITY:-}" && -S "/tmp/.X11-unix/X$X11_DISPLAY_NUM" ]]; then
    FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/examples/x11_handshake_smoke.flash" --check
    FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/examples/x11_handshake_smoke.flash" -o "$BUILD/x11_handshake_smoke"
    if "$BUILD/x11_handshake_smoke"; then
        FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/examples/x11_app_smoke.flash" --check
        FLASH_HOME="$FLASH_ROOT" "$FLASH_ROOT/flashc" "$ROOT/examples/x11_app_smoke.flash" -o "$BUILD/x11_app_smoke"
        "$BUILD/x11_app_smoke"
    else
        handshake_status=$?
        if [ "$handshake_status" -eq 2 ]; then
            echo "x11_handshake_smoke: skipped (runtime X11 unavailable)"
        else
            exit "$handshake_status"
        fi
    fi
else
    if [[ -n "$DISPLAY_VALUE" ]]; then
        echo "x11_handshake_smoke: skipped (DISPLAY $DISPLAY_VALUE socket unavailable or unauthenticated)"
    else
        echo "x11_handshake_smoke: skipped (no DISPLAY environment)"
    fi
fi

tmp_emit_guard_dir=$(mktemp -d /tmp/flashy_emit_guard.XXXXXX)
tmp_fallback_dir=$(mktemp -d /tmp/flashy_emit_fallback.XXXXXX)
tmp_readonly_src_dir=$(mktemp -d /tmp/flashy_src_guard.XXXXXX)
guard_shim_target="$tmp_emit_guard_dir/foundation_test_emit_guard.zag"
chmod a-w "$tmp_emit_guard_dir"
if ! FLASH_HOME="$FLASH_ROOT" FLASH_TMPDIR="$tmp_fallback_dir" "$FLASH_ROOT/flashc" "$ROOT/tests/foundation_test.flash" --emit-zag -o "$guard_shim_target" >/tmp/flashy_emit_guard.log 2>&1; then
    echo "emit_zag_fallback_guard: flashc failed"
    cat /tmp/flashy_emit_guard.log
    exit 1
fi
if [ -f "$guard_shim_target" ]; then
    echo "emit_zag_fallback_guard: failed (wrote into a non-writable output directory)"
    exit 1
fi
if [ -f "$tmp_fallback_dir/foundation_test_emit_guard.zag" ]; then
    echo "emit_zag_fallback_guard: ok"
else
    echo "emit_zag_fallback_guard: failed (fallback output missing)"
    exit 1
fi

sed "s#@import(\"\\..\\/src\\/flashy\\.flash\")#@import(\"$ROOT/src/flashy.flash\")#g" \
    "$ROOT/tests/foundation_test.flash" > "$tmp_readonly_src_dir/foundation_test.flash"
chmod a-w "$tmp_readonly_src_dir"
chmod a-w "$tmp_readonly_src_dir/foundation_test.flash"
if ! FLASH_HOME="$FLASH_ROOT" FLASH_TMPDIR="$tmp_fallback_dir" "$FLASH_ROOT/flashc" "$tmp_readonly_src_dir/foundation_test.flash" --emit-zag --emit-manifest -o "$guard_shim_target" >/tmp/flashy_emit_guard_manifest.log 2>&1; then
    echo "emit_manifest_fallback_guard: flashc failed"
    cat /tmp/flashy_emit_guard_manifest.log
    exit 1
fi
if [ -f "$guard_shim_target" ] || [ -f "$tmp_readonly_src_dir/flash.manifest" ]; then
    echo "emit_manifest_fallback_guard: failed (wrote into restricted source/target dir)"
    exit 1
fi
if [ -f "$tmp_fallback_dir/foundation_test_emit_guard.zag" ] && [ -f "$tmp_fallback_dir/flash.manifest" ]; then
    echo "emit_manifest_fallback_guard: ok"
else
    echo "emit_manifest_fallback_guard: failed (fallback outputs missing)"
    exit 1
fi

chmod u+w "$tmp_emit_guard_dir" "$tmp_fallback_dir" "$tmp_readonly_src_dir"
if [ -f "$tmp_readonly_src_dir/foundation_test.flash" ]; then
  chmod u+w "$tmp_readonly_src_dir/foundation_test.flash"
fi

cleanup_tmp_dir "$tmp_emit_guard_dir"
cleanup_tmp_dir "$tmp_fallback_dir"
cleanup_tmp_dir "$tmp_readonly_src_dir"
