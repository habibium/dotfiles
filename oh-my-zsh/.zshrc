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
    /opt/homebrew/share/zsh/site-functions
    $fpath
)

source $ZSH/oh-my-zsh.sh

# ─── Prompt (must come AFTER oh-my-zsh.sh so it isn't overwritten) ─────────
eval "$(starship init zsh)"

# ─── Environment Variables ─────────────────────────────────────────────────
# Homebrew (sets PATH, MANPATH, HOMEBREW_PREFIX, INFOPATH, etc.)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Bun
export BUN_INSTALL="$HOME/.bun"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_NDK_HOME="$ANDROID_HOME/ndk/27.1.12297006"

# ─── PATH (consolidated, unique entries) ───────────────────────────────────
typeset -U path PATH  # Ensure unique entries

path=(
    $HOME/.local/bin
    $BUN_INSTALL/bin
    $HOME/.deno/bin
    $HOME/.lmstudio/bin
    /Users/Shared/DBngin/postgresql/18.1/bin
    $ANDROID_HOME/emulator
    $ANDROID_HOME/platform-tools
    $ANDROID_NDK_HOME
    $HOME/.antigravity/antigravity/bin
    $HOME/.opencode/bin
    $path
)
export PATH

# ─── Completion Styling ────────────────────────────────────────────────────
zstyle ':completion:*' menu select

# ─── Mise (activate AFTER PATH so shims take precedence) ───────────────────
eval "$(mise activate zsh)"

# ─── Bun completions ───────────────────────────────────────────────────────
[ -s "$BUN_INSTALL/_bun" ] && source "$BUN_INSTALL/_bun"

# ─── Antigravity IDE (auto-managed by installer) ───────────────────────────
export PATH="$HOME/.antigravity-ide/antigravity-ide/bin:$PATH"

# ─── pnpm (auto-managed by `pnpm setup`) ───────────────────────────────────
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME/bin:"*) ;;
  *) export PATH="$PNPM_HOME/bin:$PATH" ;;
esac
# pnpm end
