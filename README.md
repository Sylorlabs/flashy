# Flashy

Flashy is an independent, pure-Flash native UI toolkit in active development. Scene keys, state, geometry, layout, input coordinates, renderer arithmetic, actions, and protocol fields use Flash's native balanced-ternary `t9` and `t27` families. Byte units are confined to required UTF-8, RGBA, and Linux display-protocol boundaries. The current foundation includes a public multiwindow `App`/`Window` lifecycle, deterministic retained scene graph, accessible interaction, strict automation, Wayland and X11 wire framing, truthful backend capabilities, and a real pure-Flash AF_UNIX transport path.

It is not Flashy 1.0 yet. Live-compositor input and clipboard certification, full XKB includes/compose/dead-key/caps/group/repeat behavior, touch/tablet input, IME, AT-SPI, production text shaping, hot patching, full controls, 3D, and path tracing remain pending. Hardware acceleration is uncertified. The CLI reports those boundaries instead of silently claiming fallback execution as hardware.

## Build and test

Flash is the only compiler/runtime dependency. With `Flashy` and `flash` as sibling directories:

```bash
scripts/test.sh
```

### Source-first compiler workflow

Flashy does not carry or apply downstream compiler patches. Reusable language,
emitter, native-codegen, and Linux-runtime fixes live in the authoritative
`/home/micah/Desktop/Sylorlabs/flash` source tree. `scripts/test.sh` first runs
that checkout's canonical `build.sh`, then runs Flashy's suites with the freshly
rebuilt compiler. It fails if the real source checkout is unavailable instead
of testing a patched copy or a stale binary.

Applications declare Flashy as a named path dependency:

```toml
[deps]
flashy = { path = "../Flashy" }
```

and import it with an ordinary Flash alias:

```flash
@import("flashy") as fy
```

Named dependency function, type, and enum references are compiler- and runtime-tested. The current self-hosted compiler flattens one dependency alias into the compilation unit; collision-safe composition of multiple packages exporting the same declaration name remains unfinished.

The pure-Flash CLI provides compiler-backed project workflows:

```bash
flashy init
flashy check
flashy build
flashy run
flashy test
flashy assets assets/icon.svg
```

`dev` currently performs a controlled rebuild and run. It explicitly reports that hot patching is pending; it does not present restart behavior as hot reload. Project and asset paths are restricted before reaching the shell-backed process boundary.

## Implemented capability matrix

| Capability | Status |
| --- | --- |
| Pure-Flash toolkit source | Implemented |
| Pure-Flash CLI workflows | `init`, `check`, `build`, `run`, `test`, `assets`, `doctor`, and inspector API guidance; fixed-project end-to-end tested |
| Named `flash.mod` path import | Implemented for aliased dependency references; collision-safe multi-package namespaces pending |
| Public `App` / `Window` lifecycle | Implemented for explicit headless, Wayland foundation, and X11; multiwindow ownership tested |
| Retained keyed nodes | Implemented |
| Versioned stable state handles | Implemented |
| Function-value event handlers | `fn(*EventContext, Event) void` bindings implemented for non-capturing Flash functions; stable state keys avoid pointer capture |
| Reconciliation lifecycle diagnostics | Mount, keyed update, unmount, focus preservation, state preservation, and schema migration counters |
| Deterministic headless RGBA8 | Implemented |
| Damage and idle redraw suppression | Implemented |
| 2D geometry and effects foundation | `3^6` fixed-point transforms and composition, explicit clipping, closed polygon fills, adaptive curvature-based quadratic/cubic Bézier flattening capped at `3^3` subdivisions, round/bevel/bounded-miter joins, round caps, 3x3 coverage antialiasing, linear gradients, premultiplied layers, alpha masks, bounded box blur, drop shadows, and color matrix with deterministic pixel transforms; remaining filter catalog is pending |
| Semantic role/name/test-id locators | Implemented |
| Local semantic automation protocol | Public owner-only AF_UNIX listener and external runner foundation implemented; bounded framing, t27 identities, typed statuses, ordered requests, exact I/O, and terminal malformed/truncated/oversized handling are native-tested both in-process and across separate server/runner processes |
| Pointer hit testing and capture | Implemented |
| Keyboard focus and activation | Implemented |
| Control primitives | Button, toggle, radio, interactive slider, progress, editable text field, scroll state, tab, menu item, and dialog foundations |
| Replaceable theme tokens and recipes | Implemented foundation for colors, spacing, and minimum targets |
| Typed layout | Auto, pixel, and percent lengths; min/max constraints; margins; row/column wrapping; stack alignment; deterministic grid foundation |
| Layout and accessibility checks | Overlap, clipping, invalid geometry/ranges, target size, semantic labels, contrast, and spacing-grid enforcement foundation |
| Inspector data | Retained hierarchy, computed bounds, focus order, dirty state, semantics, reconciliation decisions, and per-node violations |
| Linux syscall substrate | Implemented foundation |
| AF_UNIX packed-byte transport | Implemented and runtime-tested |
| Wayland wire framing | Implemented foundation; strict frame sizes, signed 24.8 boundary conversion, malformed frames, fake peer, and real AF_UNIX transport tested |
| X11 setup and core window framing | Implemented foundation; fake-peer tested |
| Linux X11 window lifecycle | Authenticated persistent create/map/event/query/destroy smoke-tested on local `:0` |
| Linux X11 CPU presentation | Server-format-aware core `PutImage`; ordered live-server round trip verified at 160x90 |
| X11 process/window association | `_NET_WM_PID` written and read back for each live smoke window |
| X11 close protocol and metadata | `WM_PROTOCOLS`, `WM_DELETE_WINDOW`, `WM_NAME`, `_NET_WM_NAME`, and `WM_CLASS` foundation |
| X11 keyboard input | Server-provided core keyboard and modifier maps drive semantic keys and text; Shift and Control are authoritative, while Lock and Mod1-Mod5 fail closed instead of being guessed as Alt, Meta, or a layout |
| Clipboard and primary selections | Public typed copy, read, release, copy-selection, and paste-to-focused-field APIs; deterministic headless storage and bounded X11 `UTF8_STRING` transfer are fake-peer native-tested. Core Wayland `wl_data_device_manager` v1 Clipboard selection integration is implemented and focused fake-peer tested; Wayland Primary is explicitly `Unsupported`, and live-compositor/native certification remains blocked on the ordered multi-FD receive boundary described below. |
| Linux Wayland windows and input | Direct registry/bind and xdg-shell lifecycle; `wl_seat` bound up to v3 with pointer and keyboard capability, release, hotplug, focus, and multiwindow routing; exact ordered keymap-authority/input FIFO; bounded XKB-v1 subset; strict frame schema, FD ownership/cardinality, keymap-size, state, and queue bounds; memfd + `wl_shm` CPU presentation and fake-peer native coverage implemented |
| Unicode text foundation | Bounded UTF-8 validation/decoding, malformed-input errors, combining/ZWJ/regional grapheme navigation, grapheme-index/byte-boundary conversion, line counting, reversed selections, selection replacement, keyboard extension, select-all, cluster-atomic forward/backward deletion, and keyed selection preservation/clamping implemented; full UAX #29 tables/conformance, bidi, shaping, fonts, and IME pending |
| SVG assets | Bounded signed-integer viewport and single-subpath parser with typed errors; rectangle/circle/line/path scenes; absolute and relative `M/L/H/V/Q/T/C/S/A/Z` commands with repeated parameter groups; compatible-control reflection for smooth curves; shared adaptive quadratic/cubic flattening; and deterministic axis-aligned elliptical-arc radius correction, large-arc/sweep selection, and 27-segment flattening with exact CPU raster goldens. Path coordinates, reflected controls, and radii are bounded to `3^9`; arc flags are exactly `0` or `1`; zero radii become lines; reflection resets after any incompatible segment; and `Z/z` must terminate the path. Arc x-axis rotation is intentionally restricted to zero and every nonzero value fails closed; decimals/exponents, multiple subpaths, rotated arcs, strokes/general styling, gradients, and animation remain pending |
| Raw pixel assets | Bounded RGBA8 memory/file decode with explicit dimensions and stride, straight-to-premultiplied conversion, premultiplied validation, typed malformed-input errors, and deterministic CPU-surface output |
| PNG/APNG assets | Pure-Flash CRC/Adler validation, stored/fixed/dynamic DEFLATE, all five row filters, sequential and Adam7 decoding for every legal static color/depth combination, plus bounded APNG sequence/frame validation, rational timing, SOURCE/OVER blending, and NONE/BACKGROUND/PREVIOUS disposal; deterministic RGBA8 static PNG and caller-controlled APNG encode implemented |
| JPEG assets | Pure-Flash bounded 8-bit baseline and progressive decode for grayscale and YCbCr, interleaved and non-interleaved scans, arbitrary 1-4 sampling factors, partial edges, canonical Huffman tables, restart intervals, progressive DC/AC first and refinement scans, EOB runs, dequantization, deterministic balanced-integer IDCT, and premultiplied RGBA8 output; CMYK/YCCK, JPEG encoding, and metadata color management pending |
| AT-SPI accessibility transport | Not implemented |
| Hot reload | Not implemented |
| 3D and CPU path tracing | Not implemented |
| Flash hardware acceleration | Uncertified |

`BackendKind.Auto` does not silently select headless. `App` tries a native Wayland registry and required xdg-shell globals first, then authenticated X11.

The Wayland gate uses real Unix socket pairs and real `SCM_RIGHTS` transfer with a pure-Flash fake compositor. It covers registry discovery, versioned binding, xdg configure/ping/close handling, dimension-safe shared-memory presentation, `wl_seat` binding up to v3, and the core Clipboard selection protocol. Pointer and keyboard capability gain/loss, v3 child release, hotplug with fresh object identities, focus, semantic keys, text, and routing across multiple windows are native-tested. Keymap map/withdrawal/rejection markers, raw input frames, and App-visible clipboard transitions share one bounded FIFO, while `wl_data_source.send` is serviced immediately at its wire position from immutable generation bytes. XKB-v1 bytes and descriptor ownership remain at the protocol boundary; strict schema, descriptor cardinality, size, pressed-key, surface-identity, and queue bounds fail closed. The shared parser intentionally accepts only a bounded XKB-v1 subset, and Shift, Control, Alt, or Meta are reported only when parsed modifier bindings and pressed-key evidence establish those roles. Full XKB includes, compose and dead keys, Caps Lock, nonzero groups, repeat, touch/tablet, IME, and live-compositor/live-input verification remain pending.

Wayland guarantees the order of passed descriptors, but does not require an ancillary FD to be attached to the stream byte that completes its logical message. The checked-in production receiver still associates descriptors with individual `recvmsg` frame reads rather than maintaining independent connection-owned byte and FD FIFOs. A compositor may therefore legally batch or split keymap/clipboard FD traffic in a shape that this receiver rejects. Focused one-frame fake peers do not certify that boundary; live Wayland clipboard and keyboard-FD support must remain uncertified until the unified schema-driven multi-FD receiver is integrated and its native gate passes.

The X11 gates authenticate, create and map persistent windows, retain batched server events, present CPU surfaces using the advertised root visual, verify `_NET_WM_PID` against the running process, synchronize through subsequent replies, and destroy window/GC resources. Keyboard translation consumes server-provided core keyboard and modifier maps rather than assigning a US or other guessed layout. Shift and Control are authoritative; Lock and Mod1-Mod5 states fail closed because the core protocol does not establish their semantic roles. Headless operation is explicit. Headless rendering identifies itself as emulation and never as hardware acceleration.

Clipboard callers choose `ClipboardKind.Clipboard` or `ClipboardKind.Primary` and receive an explicit `ClipboardStatus`; reads own a `ClipboardReadResult` that must be freed. Headless storage is deterministic and tied to a stable live-window index. The X11 path owns only `UTF8_STRING`, uses exact core selection/property framing, preserves normal event FIFO order, bounds values to 260100 bytes, and retires ambiguous or partial protocol streams. Explicit release uses a bounded server-grab transaction so it cannot clear a foreign owner in the ownership-check race. CurrentTime acquisition remains an X11 server-time trust boundary, and same-owner replacement with a different nonzero timestamp fails closed. `STRING`, `TARGETS`, `MULTIPLE`, `INCR`, legacy encoding guesses, and live-X-server clipboard certification are not claimed.

The Wayland path implements only `ClipboardKind.Clipboard` through optional `wl_data_device_manager` v1 and accepts exactly `text/plain;charset=utf-8`; the primary-selection extension, drag-and-drop publication, target negotiation, and alternate MIME aliases are not implemented. Values are valid UTF-8 and bounded to 260100 bytes. Copy and read require current keyboard focus plus an authoritative serial captured from the same seat/surface; serial value zero is valid, and the public API timestamp is never treated as a Wayland serial. A focused local read copies the retained generation directly and never opens a self-transfer pipe. Owner release and owner-window close use unconditional `wl_data_source.destroy` plus ordered callback barriers without requiring a fresh serial or sending `set_selection(NULL)`. Bytes for every source generation remain available to preceding `source.send` events until cancellation/destroy reaches its exact barrier; transfers share one caller deadline, clean all pipe endpoints, and fail closed on partial display transport.

Core selection events do not identify whether a newly offered object mirrors this client's own source. To avoid a single-thread self-receive deadlock, Flashy's conservative v1 rule keeps Local authority while an uncancelled local source epoch exists, destroys uncorrelated offers in that epoch as possible mirrors, and accepts remote authority only after the matching source cancellation or destroy barrier. A foreign replacement that arrives without such a cancellation can therefore remain hidden until that epoch ends. The protocol state is bounded to 27 source records, 27 offers, and 27 MIME entries per offer. Client IDs are allocated densely in the legal client range while retaining one logical destroy-callback obligation per live source; exhausted source, offer, MIME, queue, or ID capacity reports `ResourceLimit` or retires a malformed/over-limit connection rather than reusing an unproven identity.

The in-process automation foundation now has strict locators by role/name, test ID, key, text, and retained value. Click, double-click, hover, modifier-aware press, fill, type, focus, blur, scroll, grapheme-indexed selection, and text-edit commands are deterministic. Visibility, enabled state, focus, value, text, selection, exact geometry, action emission, and layout-violation assertions fail closed when a locator is absent or ambiguous. The implemented editor segmentation is deliberately bounded to the tested combining, ZWJ, and regional-indicator cases; full UAX #29 conformance, shaping, bidi, and composition/IME remain pending.

The local automation transport foundation frames strict semantic requests over a caller-owned AF_UNIX stream. It currently dispatches click, focus, fill, type, and semantic-key press plus text, focus, and visibility assertions. Request IDs and key/state locator identities remain balanced-ternary `t27` values and are encoded only at the wire boundary. Frames and UTF-8 fields are bounded; prefix and payload reads share one deadline; partial, malformed, oversized, or incomplete-write streams are retired instead of being resynchronized by guesswork. Missing and ambiguous locators return typed responses before action dispatch. A native external gate now launches separate Flash server and runner processes, waits for a socket inside a private `0700` temporary parent, executes a real button click and visibility assertion, checks both exact process statuses, and requires exact socket cleanup. That private-parent proof is safe against replacement by other UIDs; arbitrary caller-selected writable parent directories are not inode-identity hardened. The full `flashy test` CLI orchestration, screenshots, virtual-time controller, and remaining Playwright-style command catalog are still pending.

No license has been added.
