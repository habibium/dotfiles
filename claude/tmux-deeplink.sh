#!/usr/bin/env bash
# Click handler for a remote "Claude done" notification (run by terminal-notifier
# -execute). The omarchy box runs in its own dedicated Ghostty tab as a bare
# `ssh` (no local tmux) with the remote tmux attached via `tmux a`. So clicking
# the notification just needs to:
#   1. focus Ghostty — it restores the tab you were last on (the omarchy tab)
#   2. switch the REMOTE tmux (over ssh) to the exact session/window/pane
#
# Args: <ssh-host> <session> <window-index> <pane-index>
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

host="$1"; sess="$2"; win="$3"; pane="$4"

open -a Ghostty

if [ -n "$host" ] && [ -n "$sess" ] && [ -n "$pane" ]; then
  ssh -o BatchMode=yes -o ConnectTimeout=6 "$host" \
    "tmux switch-client -t '$sess'; tmux select-window -t '$sess:$win'; tmux select-pane -t '$sess:$win.$pane'" \
    >/dev/null 2>&1
fi
exit 0
