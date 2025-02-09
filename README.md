# Dotfiles and Other Things Related to Setting Up a New Machine

## oh-my-zsh

```sh
# install oh-my-zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# install plugins
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-completions ${ZSH_CUSTOM:-${ZSH:-~/.oh-my-zsh}/custom}/plugins/zsh-completions

# symlink zsh configs
rm ~/.zshrc
ln -sf ~/Code/dotfiles/oh-my-zsh/.zshrc ~/.zshrc
rm $ZSH_CUSTOM/aliases.zsh
ln -sf ~/Code/dotfiles/oh-my-zsh/custom/aliases.zsh $ZSH_CUSTOM/aliases.zsh
rm $ZSH_CUSTOM/env.zsh
ln -sf ~/Code/dotfiles/oh-my-zsh/custom/env.zsh $ZSH_CUSTOM/env.zsh
```
