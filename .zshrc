# Script Behavior
setopt functionargzero

# Append History
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt appendhistory
setopt histignoredups

# Terminal Behavior
setopt extendedglob
setopt interactivecomments
bindkey -e
# Terminal Keys
typeset -A key
key[Home]=${terminfo[khome]}
key[End]=${terminfo[kend]}
key[Insert]=${terminfo[kich1]}
key[Delete]=${terminfo[kdch1]}
key[Up]=${terminfo[kcuu1]}
key[Down]=${terminfo[kcud1]}
key[Left]=${terminfo[kcub1]}
key[Right]=${terminfo[kcuf1]}
key[PageUp]=${terminfo[kpp]}
key[PageDown]=${terminfo[knp]}
[[ -n "${key[Home]}"     ]]  && bindkey  "${key[Home]}"     beginning-of-line
[[ -n "${key[End]}"      ]]  && bindkey  "${key[End]}"      end-of-line
[[ -n "${key[Insert]}"   ]]  && bindkey  "${key[Insert]}"   overwrite-mode
[[ -n "${key[Delete]}"   ]]  && bindkey  "${key[Delete]}"   delete-char
[[ -n "${key[Up]}"       ]]  && bindkey  "${key[Up]}"       up-line-or-history
[[ -n "${key[Down]}"     ]]  && bindkey  "${key[Down]}"     down-line-or-history
[[ -n "${key[Left]}"     ]]  && bindkey  "${key[Left]}"     backward-char
[[ -n "${key[Right]}"    ]]  && bindkey  "${key[Right]}"    forward-char
[[ -n "${key[PageUp]}"   ]]  && bindkey  "${key[PageUp]}"   beginning-of-buffer-or-history
[[ -n "${key[PageDown]}" ]]  && bindkey  "${key[PageDown]}" end-of-buffer-or-history

# Zsh Completion System
zstyle :compinstall filename '$HOME/.zshrc'
autoload -Uz compinit
compinit

# Prompt
autoload -Uz colors
colors
autoload -Uz promptinit
promptinit
PROMPT="%{$fg_bold[yellow]%}[%{$fg_bold[red]%}%n@%m %{$fg_bold[green]%}%1~ %{$fg_bold[blue]%}<%?>%{$fg_bold[yellow]%}]%(#.#.$) %{$reset_color%}"
#RPROMPT="TEST"

# Aliases
alias diff='colordiff'
alias ls='ls -a --color=auto'
alias dir='/bin/ls -laFs --color=auto'
alias ll='/bin/ls -lFs --color=auto'
alias grep='grep --color=auto'
alias mkdir='mkdir -p -v'
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -I'
alias ln='ln -i'
alias chown='chown --preserve-root'
alias chmod='chmod --preserve-root'
alias chgrp='chgrp --preserve-root'
alias cls=' echo -ne "\033c"'



