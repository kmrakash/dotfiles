############################
# OS Detection
############################
IS_MAC=false
IS_LINUX=false

case "$(uname)" in
  Darwin) IS_MAC=true ;;
  Linux)  IS_LINUX=true ;;
esac


############################
# Aliases
############################
alias vim="nvim"
alias cc="clear"
alias cat="bat --paging=never --style=plain"
alias zshconfig="vim ~/.zshrc"
alias zshreload="source ~/.zshrc"

# Eza
alias l="eza -l --icons --git -a"
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2 --icons --git"

# Git
alias gc="git commit -m"
alias gca="git commit -a -m"
alias gp="git push origin HEAD"
alias gpu="git pull origin"
alias gst="git status"
alias glog="git log --graph --topo-order --pretty='%w(100,0,6)%C(yellow)%h%C(bold)%C(black)%d %C(cyan)%ar %C(green)%an%n%C(bold)%C(white)%s %N' --abbrev-commit"
alias gdiff="git diff"
alias gco="git checkout"
alias gb="git branch"
alias gba="git branch -a"
alias gadd="git add"
alias ga="git add -p"
alias gcoall="git checkout -- ."
alias gr="git remote"
alias gre="git reset"


############################
# PATH (cross-platform)
############################
export PATH="$HOME/bin:$PATH"
export PATH="$HOME/.opencode/bin:$PATH"
[ -d "$HOME/.local/bin" ] && export PATH="$HOME/.local/bin:$PATH"
export NVM_DIR="$HOME/.nvm"


############################
# Homebrew and OS-specific setup
############################
BREW_PREFIX=""
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix)"
  export PATH="$BREW_PREFIX/bin:$BREW_PREFIX/sbin:$PATH"
  [ -s "$BREW_PREFIX/opt/nvm/nvm.sh" ] && source "$BREW_PREFIX/opt/nvm/nvm.sh"
  [ -s "$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm" ] \
    && source "$BREW_PREFIX/opt/nvm/etc/bash_completion.d/nvm"
  [ -s "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ] \
    && source "$BREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
fi


############################
# Linux-only
############################
if $IS_LINUX; then
  [ -s "$NVM_DIR/nvm.sh" ] && source "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
fi

if [[ $- == *i* ]]; then
  autoload -Uz compinit
  compinit
fi

if command -v fzf >/dev/null 2>&1; then
  export FZF_CTRL_R_COMMAND=""
  source <(fzf --zsh)
fi

if command -v atuin >/dev/null 2>&1; then
  export ATUIN_NOBIND="true"
  eval "$(atuin init zsh)"
  bindkey '^r' atuin-search
  bindkey '^[[A' atuin-up-search
  bindkey '^[OA' atuin-up-search
fi

if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh --cmd cd)"
fi


command -v starship >/dev/null 2>&1 && eval "$(starship init zsh)"


############################
# Docker completions (portable)
############################
if [ -d "$HOME/.docker/completions" ]; then
  fpath=("$HOME/.docker/completions" $fpath)
  autoload -Uz compinit
  compinit
fi


############################
# ZSH syntax highlighting config (gruvbox theme)
############################
[ -f "$HOME/.zshrc.local" ] && source "$HOME/.zshrc.local"

(( ${+ZSH_HIGHLIGHT_STYLES} )) || typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[path]=none
ZSH_HIGHLIGHT_STYLES[path_prefix]=none
ZSH_HIGHLIGHT_STYLES[unknown-token]=fg=red
ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=yellow
ZSH_HIGHLIGHT_STYLES[alias]=fg=blue
ZSH_HIGHLIGHT_STYLES[builtin]=fg=blue
ZSH_HIGHLIGHT_STYLES[function]=fg=blue
ZSH_HIGHLIGHT_STYLES[command]=fg=green
ZSH_HIGHLIGHT_STYLES[precommand]=fg=yellow,bold
ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=yellow
ZSH_HIGHLIGHT_STYLES[hashed-command]=fg=green
ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=cyan,underline
ZSH_HIGHLIGHT_STYLES[globbing]=fg=magenta
ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=magenta
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=magenta
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=green
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=green
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=green
ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=cyan
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=cyan
ZSH_HIGHLIGHT_STYLES[assign]=fg=yellow
ZSH_HIGHLIGHT_STYLES[redirection]=fg=yellow
ZSH_HIGHLIGHT_STYLES[comment]=fg=bright_black
ZSH_HIGHLIGHT_STYLES[named-fd]=fg=yellow
ZSH_HIGHLIGHT_STYLES[numeric-fd]=fg=yellow
ZSH_HIGHLIGHT_STYLES[arg0]=fg=blue
ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue
ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green
ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta
ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow
ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan
ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout

if command -v brew >/dev/null 2>&1; then
  [ -s "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ] \
    && source "$BREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
fi
