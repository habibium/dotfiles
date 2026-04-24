alias pwrinfo='system_profiler SPPowerDataType'
alias c='code'
alias v='nvim'
alias im='magick'
alias gurc='git reset --soft HEAD~'
alias idea='open -na "IntelliJ IDEA"'
alias lg='lazygit'

t() {
    find "$1" | sort | sed 's/[^/]*\//  /g;s/  \([^  ]\)/┃━ \1/'
}

function notify() {
  terminal-notifier -title "Command completed" -message "" -sound default
}

# Upload Mac clipboard image to remote host
# Usage: imgup <host>
function imgup() {
    local remote_host="${1:-omarchy}" # Default to 'omarchy' (or your SSH alias)
    local filename="img_$(date +%s).png"
    local local_path="/tmp/$filename"
    local remote_dest="~/$filename"

    # 1. Save clipboard to local temp file
    if ! pngpaste "$local_path" 2>/dev/null; then
        echo "❌ Clipboard does not contain an image."
        return 1
    fi

    echo "🚀 Uploading to $remote_host..."
    
    # 2. Upload to remote (Arch)
    scp -q "$local_path" "$remote_host:$remote_dest"
    
    # 3. Clean up local file
    rm "$local_path"

    # 4. Copy the REMOTE path to your LOCAL clipboard
    # This makes it ready to paste directly into OpenCode, Due to some issues opencode doesn't allow pasting .png string
    echo -n "${remote_dest%g}" | pbcopy
    
    echo "✅ Uploaded to $remote_dest"
    echo "📋 Remote path copied to clipboard! Just Cmd+V in your SSH session."
}
