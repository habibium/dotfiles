# Dotfiles and Other Things Related to Setting Up a New Machine

```sh
# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install oh-my-zsh plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# symlink zsh configs
ln -sf ~/Code/dotfiles/oh-my-zsh/.zshrc ~/.zshrc
ln -sf ~/Code/dotfiles/oh-my-zsh/custom/aliases.zsh $ZSH_CUSTOM/aliases.zsh
ln -sf ~/Code/dotfiles/oh-my-zsh/custom/env.zsh $ZSH_CUSTOM/env.zsh

# symlink tmux config
ln -sf ~/Code/dotfiles/tmux ~/.config/tmux

# symlink nvim config
ln -sf ~/Code/dotfiles/nvim ~/.config/nvim



# ------------------------------------
# ********** MacOS Only **************
# ------------------------------------

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install homebrew packages
brew bundle install --file=~/Code/dotfiles/Brewfile

# symlink Ghostty config
ln -sf ~/Code/dotfiles/ghostty ~/.config/ghostty

# symlink karabiner config
ln -sf ~/Code/dotfiles/karabiner ~/.config/karabiner
```
