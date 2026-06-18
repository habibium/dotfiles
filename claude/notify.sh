#!/usr/bin/env bash
# Claude Code notifier — fires on Stop (Claude finished a turn) and Notification
# (needs permission / has been idle). Posts a rich desktop notification that
# identifies WHICH session it is for, so you can tell apart many concurrent
# sessions across the Mac, the remote box, multiple projects, and parallel git
# worktrees of one project:
#
#     title:    <emoji> <project>
#     subtitle: <host> · <branch> · <tmux-session>:<window>
#     message:  <status / Claude's message>
#
# Delivery:
#   macOS  -> terminal-notifier (Notification Center). Click jumps to the pane.
#   Linux  -> POST to the self-hosted ntfy server; the Mac subscriber renders it
#             via terminal-notifier (out-of-band; works regardless of tmux/Ghostty
#             focus). Falls back to OSC 9 via the pane PTY if ntfy is unreachable.
#
# By default it stays quiet (macOS) while you are already looking at the active
# Ghostty pane. Set CC_NOTIFY_ALWAYS=1 to notify regardless.
# Wire it to BOTH the Stop and Notification events in settings.json.

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

input=$(cat)
ev=$(printf '%s'  "$input" | jq -r '.hook_event_name // empty')
msg=$(printf '%s' "$input" | jq -r '.message // empty')
cwd=$(printf '%s' "$input" | jq -r '.cwd // empty')
[ -n "$cwd" ] || cwd="$PWD"

# ── Identity: host · project · branch (+ tmux session) ───────────────────────
case "$(uname -s)" in
  Darwin) host="${CC_NOTIFY_HOST:-mac}" ;;
  *)      host="${CC_NOTIFY_HOST:-$(hostname -s 2>/dev/null || hostname 2>/dev/null)}" ;;
esac

proj="$(basename "$cwd")"
branch=""
if command -v git >/dev/null 2>&1; then
  # Project = the MAIN repo dir, so every worktree of a repo shares one name;
  # the branch below is what tells parallel worktrees apart.
  gcd="$(git -C "$cwd" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)"
  if [ -n "$gcd" ]; then
    proj="$(basename "$(dirname "$gcd")")"
  else
    top="$(git -C "$cwd" rev-parse --show-toplevel 2>/dev/null)"
    [ -n "$top" ] && proj="$(basename "$top")"
  fi
  branch="$(git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null)"
  [ -n "$branch" ] || branch="$(git -C "$cwd" rev-parse --short HEAD 2>/dev/null)"  # detached HEAD
fi

case "$ev" in
  Stop|SubagentStop) emoji="✅"; [ -n "$msg" ] || msg="Finished — awaiting your input" ;;
  Notification)      emoji="🔔"; [ -n "$msg" ] || msg="Waiting for you" ;;
  *)                 emoji="🔔"; [ -n "$msg" ] || msg="Notification" ;;
esac

n_title="${emoji} ${proj}"
n_sub="${host}${branch:+ · ${branch}}"

# tmux locator (also drives the click-to-jump deeplink). Appended to the subtitle.
t_sess=""; t_win=""; t_pane=""
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
  t_sess=$(tmux display -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
  t_win=$(tmux  display -p -t "$TMUX_PANE" '#{window_index}'  2>/dev/null)
  t_pane=$(tmux display -p -t "$TMUX_PANE" '#{pane_index}'    2>/dev/null)
  [ -n "$t_sess" ] && n_sub="${n_sub} · ${t_sess}:${t_win}"
fi

# One group per session so concurrent sessions don't collapse into one another.
grp="claude-${host}-${proj}-${branch}-${t_sess}-${t_win}"

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

  args=( -title "$n_title" -subtitle "$n_sub" -message "$msg"
         -sound Glass -activate com.mitchellh.ghostty -group "$grp" )
  if [ -n "$t_sess" ]; then
    tmux_bin=$(command -v tmux || echo /opt/homebrew/bin/tmux)
    args+=( -execute "$tmux_bin switch-client -t '$t_sess'; $tmux_bin select-window -t '$t_sess:$t_win'; $tmux_bin select-pane -t '$TMUX_PANE'; open -a Ghostty" )
  fi
  exec terminal-notifier "${args[@]}" >/dev/null 2>&1
fi

# ── Linux (remote over SSH): ntfy primary ────────────────────────────────────
# The Mac subscriber renders this into terminal-notifier fields. Structured body:
#   <title><<F>><subtitle><<F>><message>[<<TMUX>><ssh-host>|<sess>|<win>|<pane>]
ntfy_url="${CC_NTFY_URL-http://100.74.45.64:8090/claude}"
if [ -n "$ntfy_url" ] && command -v curl >/dev/null 2>&1; then
  body="${n_title}<<F>>${n_sub}<<F>>${msg}"
  [ -n "$t_sess" ] && body="${body}<<TMUX>>${CC_DEEPLINK_HOST:-omarchy-ts}|${t_sess}|${t_win}|${t_pane}"
  curl -fsS -m 5 -H "Title: ${proj}${branch:+ (${branch})}" -d "$body" "$ntfy_url" >/dev/null 2>&1 && exit 0
fi

# ── Fallback: OSC 9 via the tmux pane PTY (only when the pane is visible) ─────
osc="${n_title} — ${n_sub} — ${msg}"
osc=${osc//$'\e'/}; osc=${osc//$'\a'/}
tty_target=""
if [ -n "$TMUX" ] && [ -n "$TMUX_PANE" ] && command -v tmux >/dev/null 2>&1; then
  tty_target=$(tmux display -p -t "$TMUX_PANE" '#{pane_tty}' 2>/dev/null)
fi
[ -n "$tty_target" ] && [ -w "$tty_target" ] || tty_target=""
if [ -n "$tty_target" ]; then
  if [ -n "$TMUX" ]; then
    printf '\ePtmux;\e\e]9;%s\a\e\\' "$osc" >"$tty_target" 2>/dev/null
  else
    printf '\e]9;%s\a' "$osc" >"$tty_target" 2>/dev/null
  fi
fi
exit 0
