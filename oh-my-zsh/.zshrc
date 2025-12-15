# Add deno completions to search path
if [[ ":$FPATH:" != *":/Users/habib/.zsh/completions:"* ]]; then export FPATH="/Users/habib/.zsh/completions:$FPATH"; fi
export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"

plugins=(
    fzf
    z
    git
    history-substring-search
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# fpath setup
fpath=(/opt/homebrew/share/zsh/site-functions \
       ${ZSH_CUSTOM:-${ZSH:-$HOME/.oh-my-zsh}/custom}/plugins/zsh-completions/src \
       $HOME/.zfunc \
       $HOME/.docker/completions $fpath)

source $ZSH/oh-my-zsh.sh

# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
if [[ ":$PATH:" != *":$PNPM_HOME:"* ]]; then
  export PATH="$PNPM_HOME:$PATH"
fi

# Java 17
export JAVA_HOME="/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home"
# Java 21
# export JAVA_HOME="/Applications/Android Studio.app/Contents/jbr/Contents/Home"

# Android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools
export ANDROID_NDK_HOME="$HOME/Library/Android/sdk/ndk/27.1.12297006"
export PATH=$PATH:$ANDROID_NDK_HOME

# DBNgin PostgreSQL 17
export PATH=/Users/Shared/DBngin/postgresql/17.0/bin:$PATH

# Yarn
# export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"

# PHP Composer
export PATH="$PATH:$HOME/.config/composer/vendor/bin"

# Completion system
autoload -Uz compinit
compinit
zstyle ':completion:*' menu select
. "/Users/habib/.deno/env"

# Added by LM Studio CLI (lms)
export PATH="$PATH:/Users/habib/.lmstudio/bin"
# End of LM Studio CLI section

# bun completions
[ -s "/Users/habib/.bun/_bun" ] && source "/Users/habib/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"




. "$HOME/.local/bin/env"
