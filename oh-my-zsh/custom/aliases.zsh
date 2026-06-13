# ─── Common (both OSes) ────────────────────────────────────────────────────
alias c='code'
alias v='nvim'
alias im='magick'
alias gurc='git reset --soft HEAD~'
alias lg='lazygit'

# Socket Firewall Aliases
# JavaScript/TypeScript
alias npm="sfw npm"
alias yarn="sfw yarn"
alias pnpm="sfw pnpm"

# Python
alias pip="sfw pip"
alias pip3="sfw pip3"
alias uv="sfw uv"

# Rust
alias cargo="sfw cargo"

# Go
alias go="sfw go"

# Java/Scala/Kotlin
alias mvn="sfw mvn"
alias gradle="sfw gradle"

# Ruby
alias gem="sfw gem"
alias bundle="sfw bundle"

# .NET
alias dotnet="sfw dotnet"

t() {
    find "$1" | sort | sed 's/[^/]*\//  /g;s/  \([^  ]\)/┃━ \1/'
}

# ─── Platform-specific ─────────────────────────────────────────────────────
case $OSTYPE in
  darwin*)
    alias pwrinfo='system_profiler SPPowerDataType'
    alias idea='open -na "IntelliJ IDEA"'

    notify() {
      terminal-notifier -title "Command completed" -message "" -sound default
    }

    # Upload Mac clipboard image to remote host.
    # Usage: imgup <ssh-host>
    imgup() {
        local remote_host="${1:-omarchy}"
        local filename="img_$(date +%s).png"
        local local_path="/tmp/$filename"
        local remote_dest="~/$filename"

        if ! pngpaste "$local_path" 2>/dev/null; then
            echo "❌ Clipboard does not contain an image."
            return 1
        fi

        echo "🚀 Uploading to $remote_host..."
        scp -q "$local_path" "$remote_host:$remote_dest"
        rm "$local_path"

        # Copy the REMOTE path to the LOCAL clipboard for easy paste into a
        echo -n "${remote_dest}" | pbcopy

        echo "✅ Uploaded to $remote_dest"
        echo "📋 Remote path copied to clipboard! Just Cmd+V in your SSH session."
    }
    ;;
  linux*)
    alias conda0='conda init --all --reverse'
    alias conda1='~/.miniconda3/bin/conda init bash; ~/.miniconda3/bin/conda init zsh'

    notify() {
      command -v notify-send >/dev/null 2>&1 && notify-send "Command completed"
    }
    ;;
esac
