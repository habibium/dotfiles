alias pwrinfo='system_profiler SPPowerDataType'
alias c='code'
alias v='nvim'
alias im='magick'
alias gurc='git reset --soft HEAD~'
alias idea='open -na "IntelliJ IDEA"'
alias conda0='conda init --all --reverse'
alias conda1='~/.miniconda3/bin/conda init bash; ~/.miniconda3/bin/conda init zsh'
alias bundletool="java -jar /usr/local/lib/bundletool/bundletool.jar"

t() {
    find "$1" | sort | sed 's/[^/]*\//  /g;s/  \([^  ]\)/┃━ \1/'
}
