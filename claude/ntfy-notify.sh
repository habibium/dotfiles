#!/usr/bin/env bash
# Mac-side ntfy subscriber callback. `ntfy subscribe` runs this for every
# incoming message (driven by the com.habib.ntfy-claude LaunchAgent) and exports
# the message as NTFY_* env vars. We render it into a native macOS notification
# via terminal-notifier — in the GUI (Aqua) session, so it shows regardless of
# tmux / pane / Ghostty focus.
#
# The remote hook sends a structured body:
#     <title><<F>><subtitle><<F>><message>[<<TMUX>><ssh-host>|<sess>|<win>|<pane>]
# The <<F>> fields map to terminal-notifier -title/-subtitle/-message; the
# optional <<TMUX>> routing makes the notification click-to-jump (tmux-deeplink.sh).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

raw="${NTFY_MESSAGE:-}"

# Split display fields (before <<TMUX>>) from the deeplink routing (after).
disp="${raw%%<<TMUX>>*}"
route=""
[ "$disp" != "$raw" ] && route="${raw#*<<TMUX>>}"

# Display fields: <title><<F>><subtitle><<F>><message>
n_title=""; n_sub=""; n_msg=""
{
  IFS= read -r n_title
  IFS= read -r n_sub
  IFS= read -r n_msg
} < <(printf '%s' "$disp" | awk -F'<<F>>' '{print $1; print $2; print $3}')

# Plain/legacy message (no <<F>> structure): show it as the message.
if [ -z "$n_sub" ] && [ -z "$n_msg" ]; then
  n_msg="$n_title"; n_title="${NTFY_TITLE:-Claude Code}"
fi
[ -n "$n_title" ] || n_title="Claude Code"
[ -n "$n_msg" ]   || n_msg="$n_title"

args=( -title "$n_title" -message "$n_msg" -sound Glass -activate com.mitchellh.ghostty )
[ -n "$n_sub" ] && args+=( -subtitle "$n_sub" )

if [ -n "$route" ]; then
  IFS='|' read -r dl_host dl_sess dl_win dl_pane <<<"$route"
  args+=( -group "ntfy-${dl_host}-${dl_sess}-${dl_win}" )
  if [ -n "$dl_host" ] && [ -n "$dl_pane" ]; then
    args+=( -execute "$HOME/Code/dotfiles/claude/tmux-deeplink.sh '$dl_host' '$dl_sess' '$dl_win' '$dl_pane'" )
  fi
else
  args+=( -group "ntfy-${n_title}" )
fi

terminal-notifier "${args[@]}" >/dev/null 2>&1 || true
