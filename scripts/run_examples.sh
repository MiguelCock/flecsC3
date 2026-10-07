#!/usr/bin/env bash
# Build and run every ported Flecs example. Exits non-zero if any fail.
set -u
cd "$(dirname "$0")/.."

fail=0
total=0
for f in $(find examples/flecs -name '*.c3' | sort); do
	total=$((total + 1))
	out=$(timeout 180 c3c compile-run "$f" --libdir . --lib flecs 2>&1)
	rc=$?
	if [ $rc -eq 0 ]; then
		printf 'PASS  %s\n' "$f"
	else
		printf 'FAIL  %s (rc=%d)\n' "$f" "$rc"
		printf '%s\n' "$out" | tail -6
		fail=$((fail + 1))
	fi
done

printf '\n%d examples, %d failures\n' "$total" "$fail"
exit $((fail > 0))
