# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples


# If not running interactively, don't do anything
case $- in
    *i*) ;;
    *) return;;
esac

if [ -f /opt/bb/share/bash-completion/completions/git ]; then
    . /opt/bb/share/bash-completion/completions/git
fi


# colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# enable color support of ls and also add handy aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'


# Add an "alert" alias for long running commands. Use like so:
# sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias c='clear'
alias gpum="git checkout main; git pull upstream main;"
alias venv="python3.12 -m venv .venv; source .venv/bin/activate;"



export BRIGHT_CYAN="\[\e[1;36m\]"
export BRIGHT_MAGENTA="\[\e[1;35m\]"
export BRIGHT_YELLOW="\[\e[1;33m\]"
export BRIGHT_GREEN="\[\e[1;32m\]"
export BRIGHT_RED="\[\e[1;31m\]"
export COLOR_RESET="\[\e[0m\]"



parse_git_branch() {
    git branch 2> /dev/null | sed -n -e 's/^\* \(.*\)/[\1]/p '
}


git_status_emoji() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local status_text
        status_text=$(git status 2>/dev/null)
        
        # Check for uncommitted changes
        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            echo '❌'=
        # Check if branch is ahead of upstream
        elif echo "$status_text" | grep -q "Your branch is ahead of"; then
            echo '📦'
        else
            echo '✅'
        fi
    fi
}


git_status_emoji() {
    if git rev-parse --is-inside-work-tree &>/dev/null; then
        local status_text
        status_text=$(git status 2>/dev/null)

        # Uncommitted changes
        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            echo '❌'
        # Diverged
        elif echo "$status_text" | grep -q "have diverged"; then
            echo '🔀'
        # Ahead
        elif echo "$status_text" | grep -q "Your branch is ahead of"; then
            echo '📦'
        # Behind
         elif echo "$status_text" | grep -q "Your branch is behind"; then
            echo '⬇️'
        # No upstream set
        elif echo "$status_text" | grep -q "no upstream branch"; then
            echo '⬛'
        # Clean and synced
        elif echo "$status_text" | grep -q "Your branch is up to date"; then
            echo '✅'
        # Uknown status=
        else
            echo '⚠️'
        fi
    fi

}

PS1="$BRIGHT_CYAN\u@\h$COLOR_RESET $BRIGHT_MAGENTA\w$COLOR_RESET \$(git_status_emoji)\$(parse_git_branch)$COLOR_RESET $BRIGHT_MAGENTA\$$COLOR_RESET "
