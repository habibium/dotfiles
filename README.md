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
ln -sf ~/Code/dotfiles/tmux ~/.config/

# symlink nvim config
ln -sf ~/Code/dotfiles/nvim ~/.config/

# symlink gitconfig
ln -sf ~/Code/dotfiles/git/.gitconfig ~/.gitconfig

# If on macOS, run the next 3 commands after the brew bundle install below
# pnpm (ensure node is installed)
curl -fsSL https://get.pnpm.io/install.sh | sh -

# yarn (ensure node is installed)
curl -o- -L https://yarnpkg.com/install.sh | bash

# global npm packages
pnpm i -g bun firebase-tools @antfu/ni serve

# ------------------------------------
# ********** MacOS Only **************
# ------------------------------------

# install homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# install homebrew packages
brew bundle install --file=~/Code/dotfiles/Brewfile

# symlink Ghostty config
ln -sf ~/Code/dotfiles/ghostty ~/.config/

# symlink karabiner config
ln -sf ~/Code/dotfiles/karabiner ~/.config/

# symlink nchat config
ln -sf ~/Code/dotfiles/nchat ~/.config/

# download and install rcmd
curl https://files.lowtechguys.com/rcmd.zip -o ~/Downloads/rcmd.zip
cd ~/Downloads && unzip rcmd.zip && mv rcmd.app /Applications
ln -sf ~/Code/dotfiles/rcmd/com.habib.reopenloop.plist ~/Library/LaunchAgents/com.habib.reopenloop.plist
launchctl load -w ~/Library/LaunchAgents/com.habib.reopenloop.plist

# enable touch id for sudo
sudo cp ~/Code/dotfiles/sudo_local /etc/pam.d/sudo_local
```
