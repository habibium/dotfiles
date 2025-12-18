# ═══════════════════════════════════════════════════════════════════════════
# OPTIMIZED ZSHRC - Habib
# ═══════════════════════════════════════════════════════════════════════════

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"

# ─── Oh-My-Zsh Performance Optimizations ───────────────────────────────────
# Skip compfix security checks (biggest speedup for compinit)
ZSH_DISABLE_COMPFIX=true
# Disable auto-update checks on startup (check manually with `omz update`)
DISABLE_AUTO_UPDATE=true
# Disable magic functions for faster paste
DISABLE_MAGIC_FUNCTIONS=true

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
    /opt/homebrew/share/zsh/site-functions
    $fpath
)

source $ZSH/oh-my-zsh.sh

# ─── Bun Completions (sourced directly for proper loading) ─────────────────
[[ -s "$HOME/.bun/_bun" ]] && source "$HOME/.bun/_bun"

# ─── Environment Variables ─────────────────────────────────────────────────
# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# PNPM
export PNPM_HOME="$HOME/Library/pnpm"

# Bun
export BUN_INSTALL="$HOME/.bun"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.1.12297006"

# ─── PATH (consolidated, unique entries) ───────────────────────────────────
typeset -U path PATH  # Ensure unique entries

path=(
    "$HOME/.local/bin"
    "/opt/homebrew/bin"
    "/opt/homebrew/sbin"
    "$PNPM_HOME"
    "$BUN_INSTALL/bin"
    "$HOME/.deno/bin"
    "$HOME/.lmstudio/bin"
    "/Users/Shared/DBngin/postgresql/17.0/bin"
    "$ANDROID_HOME/emulator"
    "$ANDROID_HOME/platform-tools"
    "$ANDROID_NDK_HOME"
    $path
)
export PATH

# ─── Completion Styling ────────────────────────────────────────────────────
zstyle ':completion:*' menu select

# ─── Mise (version manager) ────────────────────────────────────────────────
eval "$(mise activate zsh)"
