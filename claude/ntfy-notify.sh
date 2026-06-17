#!/usr/bin/env bash
# Mac-side ntfy subscriber callback. `ntfy subscribe` runs this for every
# incoming message (driven by the com.habib.ntfy-claude LaunchAgent) and exports
# the message as NTFY_* env vars. We turn it into a native macOS notification via
# terminal-notifier — this runs in the GUI (Aqua) session, so it shows reliably
# regardless of tmux / pane / Ghostty focus. This is the out-of-band path that
# delivers remote "Claude done" notifications even when the claude pane is
# backgrounded (which OSC-9-through-tmux cannot do).
#
# The remote hook may append a deeplink target to the message:
#     <display text><<TMUX>><ssh-host>|<session>|<window>|<pane>
# If present, the notification becomes click-to-jump: clicking runs
# tmux-deeplink.sh to navigate to that exact remote tmux pane.
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

title="${NTFY_TITLE:-Claude Code}"
raw="${NTFY_MESSAGE:-notification}"

display="${raw%%'<<TMUX>>'*}"
route=""
[ "$display" != "$raw" ] && route="${raw#*'<<TMUX>>'}"

args=(
  -title    "$title"
  -message  "$display"
  -sound    Glass
  -activate com.mitchellh.ghostty
  -group    "ntfy-claude-${title}"
)

if [ -n "$route" ]; then
  IFS='|' read -r dl_host dl_sess dl_win dl_pane <<<"$route"
  if [ -n "$dl_host" ] && [ -n "$dl_pane" ]; then
    args+=( -execute "$HOME/Code/dotfiles/claude/tmux-deeplink.sh '$dl_host' '$dl_sess' '$dl_win' '$dl_pane'" )
  fi
fi

terminal-notifier "${args[@]}" >/dev/null 2>&1 || true
