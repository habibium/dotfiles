#!/usr/bin/env bash
# Mac-side ntfy subscriber callback. `ntfy subscribe` runs this for every
# incoming message (driven by the com.habib.ntfy-claude LaunchAgent) and exports
# the message as NTFY_* env vars. We turn it into a native macOS notification via
# terminal-notifier — this runs in the GUI (Aqua) session, so it shows reliably
# regardless of tmux / pane / Ghostty focus. This is the out-of-band path that
# delivers remote "Claude done" notifications even when the claude pane is
# backgrounded (which OSC-9-through-tmux cannot do).
export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

title="${NTFY_TITLE:-Claude Code}"
msg="${NTFY_MESSAGE:-notification}"

terminal-notifier \
  -title    "$title" \
  -message  "$msg" \
  -sound    Glass \
  -activate com.mitchellh.ghostty \
  -group    "ntfy-claude-${title}" >/dev/null 2>&1 || true
