#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# History settings
export HISTSIZE=1000          # Number of commands in memory
export HISTFILESIZE=2000      # Number of commands in history file
export HISTCONTROL=ignoreboth # Ignore duplicates and lines starting with space
export HISTIGNORE="ls:ll:cd:pwd:bg:fg:history:clear" # Ignore common commands

# Color aliases
alias ls='ls --color=auto'
alias grep='grep --color=auto'

# Custom aliases
alias hypr='Hyprland'

# Custom Arch-themed PS1 with Git support
__git_ps1() {
  local branch=$(git branch 2>/dev/null | grep '^*' | sed 's/* //')
  if [[ -n "$branch" ]]; then
    local status=$(git status --porcelain 2>/dev/null)
    local git_color=""

    if [[ -n $status ]]; then
      git_color="\[\033[1;31m\]" # Red for dirty repo
    else
      git_color="\[\033[1;32m\]" # Green for clean repo
    fi

    echo " \[\033[1;34m\]on ${git_color} ${branch}\[\033[0m\]"
  fi
}

export PS1='\[\033[1;34m\] \[\033[0;37m\]\u \[\033[1;34m\]in \[\033[1;33m\]\w$(__git_ps1) \[\033[1;34m\]❯\[\033[0m\] '

# Fastfetch on terminal start (only once per session)
if [[ $- == *i* ]] && [[ -z $TMUX ]] && [[ -z $FASTFETCH_SHOWN ]]; then
    export FASTFETCH_SHOWN=1
    fastfetch
fi

# NVM configuration
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion