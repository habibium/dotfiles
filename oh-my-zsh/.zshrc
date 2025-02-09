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

FPATH="/opt/homebrew/share/zsh/site-functions:${FPATH}"
fpath+=${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions/src

source $ZSH/oh-my-zsh.sh

# homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# fnm
FNM_PATH="/Users/habib/Library/Application Support/fnm"
if [ -d "$FNM_PATH" ]; then
  export PATH="/Users/habib/Library/Application Support/fnm:$PATH"
  eval "`fnm env`"
fi
eval "$(fnm env --use-on-cd --version-file-strategy=recursive)"

# pnpm
export PNPM_HOME="/Users/habib/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# java
export JAVA_HOME=/Library/Java/JavaVirtualMachines/zulu-17.jdk/Contents/Home

# android
export ANDROID_HOME=$HOME/Library/Android/sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/tools
export PATH=$PATH:$ANDROID_HOME/tools/bin
export PATH=$PATH:$ANDROID_HOME/platform-tools
export PATH=$PATH:$ANDROID_HOME/cmdline-tools/latest/bin

# ruby homebrew
export PATH="$PATH:/opt/homebrew/opt/ruby/bin"
export PATH="$PATH:/opt/homebrew/lib/ruby/gems/3.3.0/bin"
export LDFLAGS="-L/opt/homebrew/opt/ruby/lib"
export CPPFLAGS="-I/opt/homebrew/opt/ruby/include"

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"


fpath+=~/.zfunc; autoload -Uz compinit; compinit

zstyle ':completion:*' menu select
