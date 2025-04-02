# Alias
alias vim="nvim"
alias cc="clear"
alias zshconfig="vim ~/.zshrc"
alias zshreload="source ~/.zshrc"

export PATH=/opt/homebrew/bin:$PATH


eval "$(starship init zsh)"

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb='git branch'
alias gba='git branch -a'
alias gadd='git add'
alias ga='git add -p'
alias gcoall='git checkout -- .'
alias gr='git remote'
alias gre='git reset'


# Work
alias vuat="echo USER_NAME=Akash-Kumar-UAT && sudo openvpn --config ~/work/vpn/UAT-Instance_Akash-Kumar-UAT_UAT-Instance.ovpn --auth-retry interact"
# alias vuat="sudo openvpn --config ~/work/vpn/UAT-Instance_Akash-Kumar-UAT_UAT-Instance.ovpn --auth-retry interact"
alias jenkin="sudo openvpn --config ~/work/vpn/arisinfra-Akash.ovpn --auth-retry interact"
alias vprod="echo USER_NAME=Prod-AkashKumar && sudo openvpn --config ~/work/vpn/Prod-Instance_Prod-AkashKumar_Prod-Instance.ovpn --auth-retry interact"
alias vproddb="echo USER_NAME=AkashKumar-Prod-DB && sudo openvpn --config ~/work/vpn/Prod-DB_AkashKumar-Prod-DB_Prod-DB-Access.ovpn --auth-retry interact"
alias generateToken="aws rds generate-db-auth-token --hostname prodarisinfra-mumbai-cluster.cluster-c3x8jplo9izp.ap-south-1.rds.amazonaws.com --port 5432 --region ap-south-1 --username akash_write_access "

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

  export NVM_DIR="$HOME/.nvm"
  [ -s "/opt/homebrew/opt/nvm/nvm.sh" ] && \. "/opt/homebrew/opt/nvm/nvm.sh"  # This loads nvm
  [ -s "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm" ] && \. "/opt/homebrew/opt/nvm/etc/bash_completion.d/nvm"  # This loads nvm bash_completion
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"

# bun completions
[ -s "/Users/kmrakash/.bun/_bun" ] && source "/Users/kmrakash/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
export PATH="/opt/homebrew/sbin:$PATH"

# neovim
export PATH=$PATH:/path/to/nvim


# Automatically attach the session into a tmux session
# if command -v tmux &> /dev/null && [ -z "$TMUX" ]; then
#     tmux attach-session -t default || tmux new-session -s default
# fi
# The following lines have been added by Docker Desktop to enable Docker CLI completions.
fpath=(/Users/kmrakash/.docker/completions $fpath)
autoload -Uz compinit
compinit
# End of Docker CLI completions

source $(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# Disable underline
(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
# Change colors
# export ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[precommand]=fg=blue
# export ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue

# Activate autosuggestions
source $(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh
