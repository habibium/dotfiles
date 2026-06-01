# Replicate Ghostty's `notify-on-command-finish` INSIDE tmux.
#
# tmux consumes Ghostty's shell-integration prompt marks (OSC 133), so Ghostty's
# native notify-on-command-finish never fires inside it. This times each command
# in zsh and notifies via the platform's native path:
#
#   macOS (local sessions):
#     Post to Notification Center via terminal-notifier, which tmux cannot
#     intercept. Click to switch tmux to the originating pane.
#
#   Linux (remote shell over SSH inside a remote tmux):
#     Emit an OSC 9 sequence wrapped in a tmux DCS passthrough envelope. The
#     remote tmux re-emits the inner OSC, SSH carries it back, and Ghostty on
#     the Mac shows the notification. Requires `set -g allow-passthrough on` in
#     the remote tmux.
#
# Active only inside tmux -- outside tmux Ghostty's own feature already works
# and running here too would double-notify.
#
# Tunables (set before this file loads, e.g. in env.zsh):
#   LCN_THRESHOLD   seconds; commands faster than this never notify (default 10)
#   LCN_ALWAYS=1    macOS: notify even while watching the active pane

if [[ -n $TMUX ]]; then

  : ${LCN_THRESHOLD:=10}

  _lcn_preexec() { _lcn_cmd=$1; _lcn_start=$SECONDS; }

  _lcn_notify_darwin() {
    command -v terminal-notifier >/dev/null 2>&1 || return
    local title=$1 subtitle=$2 body=$3

    local tmux_bin=${commands[tmux]:-/opt/homebrew/bin/tmux}
    local sess win
    sess=$(tmux display -p -t "$TMUX_PANE" '#{session_name}' 2>/dev/null)
    win=$(tmux display -p -t "$TMUX_PANE" '#{window_index}' 2>/dev/null)
    local click="$tmux_bin switch-client -t '$sess'; $tmux_bin select-window -t '$sess:$win'; $tmux_bin select-pane -t '$TMUX_PANE'; open -a Ghostty"

    terminal-notifier \
      -title    "$title" \
      -subtitle "$subtitle" \
      -message  "$body" \
      -sound    Glass \
      -group    "lcn-${TMUX_PANE:-x}" \
      -execute  "$click" >/dev/null 2>&1 &!
  }

  _lcn_notify_linux() {
    # Remote-tmux path: emit OSC 9 inside a tmux DCS passthrough envelope.
    # Format: ESC P "tmux;" <doubled-ESC OSC body> ESC \
    # Inner OSC: ESC ] 9 ; <message> BEL  -- BEL terminator avoids another ESC.
    [[ -t 1 ]] || return
    local title=$1 subtitle=$2 body=$3
    local msg="${title} | ${subtitle}"
    [[ -n $body ]] && msg+=" — $body"
    msg=${msg//$'\e'/}; msg=${msg//$'\a'/}     # strip stray ctrl chars
    printf '\ePtmux;\e\e]9;%s\a\e\\' "$msg"
  }

  _lcn_precmd() {
    local code=$?
    [[ -z $_lcn_start ]] && return            # nothing ran (empty prompt)
    local elapsed=$(( SECONDS - _lcn_start ))
    unset _lcn_start
    (( elapsed < LCN_THRESHOLD )) && return

    local title
    if (( code == 0 )); then title="✅ done · ${elapsed}s"
    else                     title="❌ exit ${code} · ${elapsed}s"; fi

    local subtitle="${_lcn_cmd:0:80}"
    local body="${PWD/#$HOME/~}"

    case $OSTYPE in
      darwin*)
        [[ -z $LCN_ALWAYS ]] && _lcn_watching && return    # you're staring at it
        _lcn_notify_darwin "$title" "$subtitle" "$body"
        ;;
      linux*)
        _lcn_notify_linux  "$title" "$subtitle" "$body"
        ;;
    esac
  }

  # macOS-only: true => Ghostty is frontmost AND this is the active tmux pane.
  _lcn_watching() {
    local front
    front=$(/usr/bin/lsappinfo info -only bundleID "$(/usr/bin/lsappinfo front 2>/dev/null)" 2>/dev/null)
    [[ $front == *com.mitchellh.ghostty* ]] || return 1
    [[ $(tmux display -p -t "$TMUX_PANE" '#{pane_active}#{window_active}' 2>/dev/null) == 11 ]]
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook preexec _lcn_preexec
  add-zsh-hook precmd  _lcn_precmd
fi
