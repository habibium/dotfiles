alias pwrinfo='system_profiler SPPowerDataType'
alias c='code'
alias v='nvim'
alias im='magick'
alias gurc='git reset --soft HEAD~'
alias idea='open -na "IntelliJ IDEA"'

t() {
    find "$1" | sort | sed 's/[^/]*\//  /g;s/  \([^  ]\)/┃━ \1/'
}

function notify() {
  terminal-notifier -title "Command completed" -message "" -sound default
}
