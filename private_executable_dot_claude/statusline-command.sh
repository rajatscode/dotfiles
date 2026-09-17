#!/bin/sh

input=$(cat)
autocompact_limit=155000

used_pct=$(printf '%s' "$input" | jq -r '.context_window.used_percentage // empty')
in_tok=$(printf '%s' "$input" | jq -r '.context_window.current_usage.input_tokens // 0')
out_tok=$(printf '%s' "$input" | jq -r '.context_window.current_usage.output_tokens // 0')
cache_create=$(printf '%s' "$input" | jq -r '.context_window.current_usage.cache_creation_input_tokens // 0')
cache_read=$(printf '%s' "$input" | jq -r '.context_window.current_usage.cache_read_input_tokens // 0')
window_size=$(printf '%s' "$input" | jq -r '.context_window.context_window_size // 200000')

if [ -z "$used_pct" ]; then
    printf 'Context: no messages yet'
    exit 0
fi

ctx_tokens=$((in_tok + cache_create + cache_read))
remaining_until_compact=$(awk -v current="$ctx_tokens" -v limit="$autocompact_limit" \
    'BEGIN { remaining = (limit - current) / limit * 100; if (remaining < 0) remaining = 0; printf "%d", remaining }')

fmt_tokens() {
    if [ "$1" -ge 1000 ]; then
        printf '%dk' "$(( $1 / 1000 ))"
    else
        printf '%d' "$1"
    fi
}

printf 'Context: %s%% used (%s%% until auto-compact) | ctx: %s  in: %s  out: %s  window: %s' \
    "$(printf '%.0f' "$used_pct")" \
    "$remaining_until_compact" \
    "$(fmt_tokens "$ctx_tokens")" \
    "$(fmt_tokens "$in_tok")" \
    "$(fmt_tokens "$out_tok")" \
    "$(fmt_tokens "$window_size")"
