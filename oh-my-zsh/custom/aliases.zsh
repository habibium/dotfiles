# ─── Common (both OSes) ────────────────────────────────────────────────────
alias c='code'
alias v='nvim'
alias im='magick'
alias gurc='git reset --soft HEAD~'
alias lg='lazygit'

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
        # remote tool (e.g. OpenCode) that doesn't accept .png clipboard data.
        echo -n "${remote_dest%g}" | pbcopy

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
