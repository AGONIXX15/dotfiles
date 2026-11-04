### Added by Zinit's installer
if [[ ! -f $HOME/.local/share/zinit/zinit.git/zinit.zsh ]]; then
    print -P "%F{33} %F{220}Installing %F{33}ZDHARMA-CONTINUUM%F{220} Initiative Plugin Manager (%F{33}zdharma-continuum/zinit%F{220})…%f"
    command mkdir -p "$HOME/.local/share/zinit" && command chmod g-rwX "$HOME/.local/share/zinit"
    command git clone https://github.com/zdharma-continuum/zinit "$HOME/.local/share/zinit/zinit.git" && \
        print -P "%F{33} %F{34}Installation successful.%f%b" || \
        print -P "%F{160} The clone has failed.%f%b"
fi

source "$HOME/.local/share/zinit/zinit.git/zinit.zsh"
autoload -Uz _zinit
(( ${+_comps} )) && _comps[zinit]=_zinit

# Load a few important annexes, without Turbo
# (this is currently required for annexes)
zinit light-mode for \
    zdharma-continuum/zinit-annex-as-monitor \
    zdharma-continuum/zinit-annex-bin-gem-node \
    zdharma-continuum/zinit-annex-patch-dl \
    zdharma-continuum/zinit-annex-rust

### End of Zinit's installer chunk

zinit light zsh-users/zsh-autosuggestions

# autocomplete
zinit light zsh-users/zsh-completions

#
autoload -Uz compinit
compinit

zinit light Aloxaf/fzf-tab

zinit snippet OMZP::extract
zinit snippet OMZP::sudo   # double ESC to repeat last command with sudo

zinit snippet OMZP::git
alias ls='eza --icons always'

export PATH="/home/agox/.local/bin:$PATH"
export PATH="$HOME/flutter/bin:$PATH"
export PATH="$HOME/.cargo/bin/:$PATH"
export PATH="$PATH:$HOME/.ghcup/bin/"
export PATH="$PATH:$HOME/.elan/bin/"
HISTFILE=~/.zsh_history
HISTSIZE=10000
SAVEHIST=10000
setopt share_history hist_ignore_dups
eval "$(zoxide init zsh --cmd cd)"
alias cat='bat --paging=never'
alias ll='eza -l --icons --git'
eval "$(starship init zsh)"
export CHROME_EXECUTABLE=/usr/bin/brave

if [[ $(pgrep -xc kitty) -le 1 ]]; then fastfetch; fi

# debe ir al final
zinit light zsh-users/zsh-syntax-highlighting
