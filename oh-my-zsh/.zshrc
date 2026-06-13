# ─── Oh-My-Zsh Setup ───────────────────────────────────────────────────────
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME=""  # Using starship instead of an omz theme

# ─── Oh-My-Zsh Performance Optimizations ───────────────────────────────────
# Skip compfix security checks (run manually with `compinit`, `compaudit`)
ZSH_DISABLE_COMPFIX=true
# Disable auto-update checks on startup (check manually with `omz update`)
DISABLE_AUTO_UPDATE=true

# ─── Plugins ───────────────────────────────────────────────────────────────
plugins=(
    git
    z
    fzf
    history-substring-search
    zsh-autosuggestions
    zsh-syntax-highlighting  # Must be last
)

# ─── fpath (completion directories) ────────────────────────────────────────
# Add BEFORE sourcing oh-my-zsh
fpath=(
    $HOME/.zsh/completions
    $fpath
)
case $OSTYPE in
  darwin*) fpath=(/opt/homebrew/share/zsh/site-functions $fpath) ;;
esac

source $ZSH/oh-my-zsh.sh

# ─── Prompt (must come AFTER oh-my-zsh.sh so it isn't overwritten) ─────────
eval "$(starship init zsh)"

# ─── Environment Variables ─────────────────────────────────────────────────
# Bun
export BUN_INSTALL="$HOME/.bun"

# Android SDK (path differs per OS)
case $OSTYPE in
  darwin*)
    export ANDROID_HOME="$HOME/Library/Android/sdk"
    export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.1.12297006"
    ;;
  linux*)
    export ANDROID_HOME="$HOME/Android/Sdk"
    ;;
esac

# ─── PATH (consolidated, unique entries) ───────────────────────────────────
typeset -U path PATH  # Ensure unique entries

# Common entries (work on both OSes when the tool is installed)
path=(
    $HOME/.local/bin
    $BUN_INSTALL/bin
    $HOME/.deno/bin
    $HOME/.opencode/bin
    $ANDROID_HOME/emulator
    $ANDROID_HOME/platform-tools
    $path
)

case $OSTYPE in
  darwin*)
    # Homebrew (sets PATH, MANPATH, HOMEBREW_PREFIX, INFOPATH, etc.)
    eval "$(/opt/homebrew/bin/brew shellenv)"
    path=(
        $HOME/.lmstudio/bin
        /Users/Shared/DBngin/postgresql/18.1/bin
        $ANDROID_NDK_HOME
        $HOME/.antigravity/antigravity/bin
        $HOME/.antigravity-ide/antigravity-ide/bin
        $path
    )
    ;;
  linux*)
    path=(
        $ANDROID_HOME/tools
        $ANDROID_HOME/tools/bin
        $ANDROID_HOME/cmdline-tools/latest/bin
        $path
    )
    ;;
esac
export PATH

# ─── Completion Styling ────────────────────────────────────────────────────
zstyle ':completion:*' menu select

# ─── Mise (activate AFTER PATH so shims take precedence) ───────────────────
eval "$(mise activate zsh)"

# ─── Bun completions ───────────────────────────────────────────────────────
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"


# pnpm
case $OSTYPE in
  darwin*) export PNPM_HOME="$HOME/Library/pnpm" ;;
  linux*)  export PNPM_HOME="$HOME/.local/share/pnpm" ;;
esac
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
