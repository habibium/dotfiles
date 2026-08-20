# Ghostty's notify-on-command-finish cannot work in a herdr pane: herdr's
# emulator consumes the shell's OSC 133 marks and has no passthrough (tested).
# Uses alerter rather than `herdr notification show` because herdr's notify API
# takes no target, so its notifications cannot be made clickable.
# alerter needs macOS notification permission; until granted it silently drops
# notifications and returns a bogus @CONTENTCLICKED.

if [[ ${HERDR_ENV:-} == 1 ]]; then

  : ${LCN_THRESHOLD:=10}

  _lcn_preexec() { _lcn_cmd=$1; _lcn_start=$SECONDS; }

  _lcn_precmd() {
    local code=$?
    [[ -n ${_lcn_start:-} ]] || return 0

    local elapsed=$(( SECONDS - _lcn_start ))
    local cmd=${_lcn_cmd:-command}
    unset _lcn_start _lcn_cmd

    (( elapsed >= LCN_THRESHOLD )) || return 0
    command -v alerter >/dev/null 2>&1 || return 0

    local icon; (( code == 0 )) && icon="✅" || icon="❌"
    local ws=${HERDR_WORKSPACE_ID:-} tab=${HERDR_TAB_ID:-}

    (
      clicked=$(alerter \
        --title    "${icon} ${cmd[1,60]}" \
        --subtitle "${PWD/#$HOME/~}" \
        --message  "${elapsed}s · exit ${code}" \
        --sender   com.mitchellh.ghostty \
        --sound    default \
        --timeout  900 \
        --group    "lcn-${HERDR_PANE_ID:-x}" 2>/dev/null)

      case $clicked in
        ''|@CLOSED|@TIMEOUT) ;;
        *)
          open -a Ghostty
          [[ -n $ws  ]] && herdr workspace focus "$ws"  >/dev/null 2>&1
          [[ -n $tab ]] && herdr tab focus       "$tab" >/dev/null 2>&1
          ;;
      esac
    ) &!
  }

  autoload -Uz add-zsh-hook
  add-zsh-hook preexec _lcn_preexec
  add-zsh-hook precmd  _lcn_precmd
fi
