#!/usr/bin/env bash
# Claude Code notifier — fires on Stop (Claude finished a turn) and Notification
# (needs permission / has been idle). Posts a desktop notification so you know a
# session needs you without having to watch it.
#
# Why a hook instead of Claude's built-in notifications: inside tmux, Claude's
# OSC 9 notifications are swallowed by tmux and never reach Ghostty. This hook
# runs as its own process and uses a path tmux cannot eat:
#
#   macOS  -> terminal-notifier (Notification Center). Clicking it jumps tmux
#             back to the originating session/window/pane and raises Ghostty.
#   Linux  -> OSC 9 wrapped in a tmux DCS passthrough envelope, written to the
#             controlling tty. The remote tmux re-emits the inner OSC, SSH
#             carries it back, and local Ghostty shows it. Requires
#             `set -g allow-passthrough on` in the remote tmux.
#
# By default it stays quiet while you are already looking at the active Ghostty
# pane (you can see it finished). Set CC_NOTIFY_ALWAYS=1 to notify regardless.
#
# Wire it to BOTH the Stop and Notification events in settings.json.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

input=$(cat)

ev=$(printf '%s' "$input"  | jq -r '.hook_event_name // empty')
msg=$(printf '%s' "$input" | jq -r '.message // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
sub=""; [ -n "$cwd" ] && sub=$(basename "$cwd")

case "$ev" in
  Stop|SubagentStop) title="✅ Claude done";  [ -n "$msg" ] || msg="Finished — awaiting your input" ;;
  Notification)      title="🔔 Claude Code";  [ -n "$msg" ] || msg="Waiting for you" ;;
  *)                 title="🔔 Claude Code";  [ -n "$msg" ] || msg="Notification" ;;
esac

# ── macOS: terminal-notifier ────────────────────────────────────────────────
if [ "$(uname -s)" = "Darwin" ]; then
  command -v terminal-notifier >/dev/null 2>&1 || exit 0

  # Stay quiet if you are already staring at this exact pane (unless forced).
  if [ -z "$CC_NOTIFY_ALWAYS" ] && [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    front=$(/usr/bin/lsappinfo info -only bundleID "$(/usr/bin/lsappinfo front 2>/dev/null)" 2>/dev/null)
    if [[ $front == *com.mitchellh.ghostty* ]] &&
       [ "$(tmux display -p -t "$TMUX_PANE" '#{pane_active}#{window_active}' 2>/dev/null)" = "11" ]; then
      exit 0
    fi
  fi

  args=( -title "$title" -message "$msg" -sound Glass -activate com.mitchellh.ghostty )
  [ -n "$sub" ] && args+=( -subtitle "$sub" -group "claude-code-${TMUX_PANE:-$sub}" )

  if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ]; then
    tmux_bin=$(command -v tmux || echo /opt/homebrew/bin/tmux)
    sess=$(tmux display -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
    win=$(tmux  display -p -t "$TMUX_PANE" '#{window_index}'  2>/dev/null)
    args+=( -execute "$tmux_bin switch-client -t '$sess'; $tmux_bin select-window -t '$sess:$win'; $tmux_bin select-pane -t '$TMUX_PANE'; open -a Ghostty" )
  fi

  exec terminal-notifier "${args[@]}" >/dev/null 2>&1
fi

# ── Linux (remote over SSH) ──────────────────────────────────────────────────
# Primary path: ntfy. POST to the self-hosted ntfy server running on this box;
# the Mac subscribes over Tailscale and shows a native notification. Fully
# out-of-band, so it reaches the Mac regardless of tmux pane focus, Ghostty
# focus, or which app is active. Override with CC_NTFY_URL; set it empty to skip.
ntfy_url="${CC_NTFY_URL-http://100.74.45.64:8090/claude}"
if [ -n "$ntfy_url" ] && command -v curl >/dev/null 2>&1; then
  ntfy_body="${title} — ${msg}"
  # Append a deeplink target so clicking the Mac notification jumps to this exact
  # remote tmux pane. Format: <<TMUX>><ssh-host>|<session>|<window>|<pane>
  if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
    dl=$(tmux display -p -t "$TMUX_PANE" "${CC_DEEPLINK_HOST:-omarchy-ts}|#{session_name}|#{window_index}|#{pane_index}" 2>/dev/null)
    [ -n "$dl" ] && ntfy_body="${ntfy_body}<<TMUX>>${dl}"
  fi
  curl -fsS -m 5 -H "Title: ${sub:-Claude Code}" -d "$ntfy_body" "$ntfy_url" >/dev/null 2>&1 && exit 0
fi

# Fallback path: OSC 9 routed to Ghostty via the tmux pane PTY. Used only if the
# ntfy POST failed (server down / off-tailnet). Hooks run with NO controlling
# terminal, so /dev/tty ENXIOs; write to the pane's own PTY device instead (the
# same device the interactive shell writes to via fd1), wrapped in a tmux
# passthrough envelope so tmux forwards the OSC 9 to Ghostty.
# Caveat: tmux only forwards passthrough from a *visible* pane, so this delivers
# only when the claude pane is the active tmux pane; a backgrounded pane gets a
# bell. (ntfy above has no such limitation — this is just a safety net.)
body="$title"
[ -n "$sub" ] && body+=" · $sub"
body+=" — $msg"
body=${body//$'\e'/}; body=${body//$'\a'/}   # strip stray control chars

tty_target=""
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
  tty_target=$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
fi
[ -n "$tty_target" ] && [ -w "$tty_target" ] || tty_target=""

if [ -n "$tty_target" ]; then
  if [ -n "$TMUX" ]; then
    printf '\ePtmux;\e\e]9;%s\a\e\\' "$body" >"$tty_target" 2>/dev/null
  else
    printf '\e]9;%s\a' "$body" >"$tty_target" 2>/dev/null
  fi
fi
exit 0
