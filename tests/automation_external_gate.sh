#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
    echo "usage: automation_external_gate.sh SERVER RUNNER" >&2
    exit 2
fi

server_binary="$1"
runner_binary="$2"
if [ ! -x "$server_binary" ] || [ ! -x "$runner_binary" ]; then
    echo "automation_external_gate: native fixtures are missing" >&2
    exit 2
fi

gate_tmp_dir=$(mktemp -d /tmp/flashy-automation-external.XXXXXX)
chmod 700 "$gate_tmp_dir"
socket_path="$gate_tmp_dir/endpoint.sock"
server_log="$gate_tmp_dir/server.log"
runner_log="$gate_tmp_dir/runner.log"
server_pid=""
runner_pid=""

cleanup_external_gate() {
    local cleanup_pid
    for cleanup_pid in "$runner_pid" "$server_pid"; do
        if [ -n "$cleanup_pid" ] && kill -0 "$cleanup_pid" 2>/dev/null; then
            kill -KILL "$cleanup_pid" 2>/dev/null || true
            wait "$cleanup_pid" 2>/dev/null || true
        fi
    done
    if [ -e "$socket_path" ] || [ -L "$socket_path" ]; then rm -f -- "$socket_path"; fi
    if [ -f "$server_log" ]; then rm -f -- "$server_log"; fi
    if [ -f "$runner_log" ]; then rm -f -- "$runner_log"; fi
    rmdir -- "$gate_tmp_dir" 2>/dev/null || true
}
trap cleanup_external_gate EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

wait_bounded() {
    local child_pid="$1"
    local label="$2"
    local ticks="$3"
    local tick=0
    while kill -0 "$child_pid" 2>/dev/null; do
        if [ "$tick" -ge "$ticks" ]; then
            kill -KILL "$child_pid" 2>/dev/null || true
            wait "$child_pid" 2>/dev/null || true
            echo "automation_external_gate: $label timed out" >&2
            return 124
        fi
        sleep 0.02
        tick=$((tick + 1))
    done
    local child_status=0
    wait "$child_pid" || child_status=$?
    if [ "$child_status" -ne 0 ]; then
        echo "automation_external_gate: $label exited $child_status" >&2
        return "$child_status"
    fi
    return 0
}

"$server_binary" "$socket_path" >"$server_log" 2>&1 &
server_pid=$!

ready=0
for ((readiness_tick = 0; readiness_tick < 250; readiness_tick += 1)); do
    if [ -S "$socket_path" ]; then ready=1; break; fi
    if ! kill -0 "$server_pid" 2>/dev/null; then
        server_status=0
        wait "$server_pid" || server_status=$?
        server_pid=""
        echo "automation_external_gate: server exited before readiness ($server_status)" >&2
        cat "$server_log" >&2
        exit 1
    fi
    sleep 0.02
done
if [ "$ready" -ne 1 ]; then
    echo "automation_external_gate: socket readiness timed out" >&2
    exit 124
fi

"$runner_binary" "$socket_path" >"$runner_log" 2>&1 &
runner_pid=$!
runner_status=0
wait_bounded "$runner_pid" "runner" 1000 || runner_status=$?
if [ "$runner_status" -ne 0 ]; then cat "$runner_log" >&2; exit "$runner_status"; fi
runner_pid=""
server_status=0
wait_bounded "$server_pid" "server" 1000 || server_status=$?
if [ "$server_status" -ne 0 ]; then cat "$server_log" >&2; exit "$server_status"; fi
server_pid=""

if ! grep -Fqx "automation_external_runner: ok" "$runner_log"; then
    echo "automation_external_gate: runner success marker missing" >&2
    cat "$runner_log" >&2
    exit 1
fi
if ! grep -Fqx "automation_external_server: ok" "$server_log"; then
    echo "automation_external_gate: server success marker missing" >&2
    cat "$server_log" >&2
    exit 1
fi
if [ -e "$socket_path" ] || [ -L "$socket_path" ]; then
    echo "automation_external_gate: exact socket path was not removed" >&2
    exit 1
fi

rm -f -- "$server_log"
rm -f -- "$runner_log"
rmdir -- "$gate_tmp_dir"
trap - EXIT
echo "automation_external_gate: ok"
