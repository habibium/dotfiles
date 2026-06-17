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

# ── Linux (remote over SSH): OSC 9 via tmux passthrough to the tty ───────────
[ -w /dev/tty ] || exit 0
body="$title"
[ -n "$sub" ] && body+=" · $sub"
body+=" — $msg"
body=${body//$'\e'/}; body=${body//$'\a'/}   # strip stray control chars
if [ -n "$TMUX" ]; then
  printf '\ePtmux;\e\e]9;%s\a\e\\' "$body" > /dev/tty
else
  printf '\e]9;%s\a' "$body" > /dev/tty
fi
