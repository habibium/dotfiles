#!/usr/bin/env bash
# Click handler for a remote "Claude done" notification (run by terminal-notifier
# -execute). The omarchy box runs in its own Ghostty tab as a bare `ssh` (no
# local tmux) with the remote tmux attached via `tmux a`. Clicking the
# notification:
#   1. focus the correct Ghostty TAB — the one whose title carries the host
#      (tmux set-titles-string starts with #h), via Ghostty's AppleScript API
#      (one-time Automation grant; no Accessibility/keystroke hack)
#   2. switch the REMOTE tmux (over ssh) to the exact session:window.pane
#
# Args: <ssh-host> <session> <window-index> <pane-index>
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

host="$1"; sess="$2"; win="$3"; pane="$4"
hbase="${host%%-*}"   # omarchy-ts / omarchy-cf -> omarchy

# ── Layer 1: focus the right Ghostty tab ─────────────────────────────────────
# Match the host token in the tab title first; fall back to the tmux session
# slot "❐ <sess> ●". osascript prints "ok"/"nomatch" on success (Ghostty was
# activated either way); empty output means the Apple-event was denied
# (Automation not granted yet) -> fall back to just bringing Ghostty forward.
focus_tab() {
  osascript - "$hbase" "$sess" 2>/dev/null <<'OSA'
on run argv
  set hostTok to item 1 of argv
  set sessTok to item 2 of argv
  tell application "Ghostty"
    activate
    repeat with w in windows
      repeat with t in tabs of w
        if (name of t) contains hostTok then
          select tab t
          focus (focused terminal of t)
          return "ok"
        end if
      end repeat
    end repeat
    repeat with w in windows
      repeat with t in tabs of w
        if (name of t) contains ("❐ " & sessTok & " ●") then
          select tab t
          focus (focused terminal of t)
          return "ok"
        end if
      end repeat
    end repeat
    return "nomatch"
  end tell
end run
OSA
}
[ -n "$(focus_tab)" ] || open -a Ghostty

# ── Layer 2: remote tmux — navigate to the exact session/window/pane ──────────
if [ -n "$host" ] && [ -n "$sess" ] && [ -n "$pane" ]; then
  ssh -o BatchMode=yes -o ConnectTimeout=6 "$host" \
    "tmux switch-client -t '$sess'; tmux select-window -t '$sess:$win'; tmux select-pane -t '$sess:$win.$pane'" \
    >/dev/null 2>&1
fi
exit 0
