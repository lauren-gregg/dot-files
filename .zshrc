setopt prompt_subst # Enables variable expansion inside PROMPT (PS1)


# Only proceed if interactive shell
[[ $- != *i* ]] && return


# Source git completions (if available)
[[ -f /opt/bb/share/bash-completion/completions/git ]] && source /opt/bb/share/bash-completion/completions/git


# Colored GCC warnings and errors
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# Aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'
alias alert='notify-send --urgency=low -i "$([[ $? = 0 ]] && echo terminal || echo error)" "$(history -1 | sed -e "s/^[ ]*[0-9]\+[ ]*//;s/[;&|][ ]*alert$//")"'
alias c='clear'
alias gpum="git checkout main; git pull upstream main;"
alias venv="python3.12 -m venv .venv; source .venv/bin/activate;"

alias aws-int="okta-awscli -v --profile integration --okta-profile integration; export AWS_PROFILE=integration;"
alias aws-core="okta-awscli -v --profile core --okta-profile core; export AWS_PROFILE=core;"
alias aws-set=". ~/cli_auth.sh;"
alias aws-check="aws sts get-caller-identity;"

alias kube-check="kubectl config current-context"
alias kube-prod1="export KUBECONFIG=~/.kube/reporting-prod-1; kubectl config current-context"
alias kube-prod2="export KUBECONFIG=~/.kube/reporting-prod-2; kubectl config current-context"
alias kube-dev2="export KUBECONFIG=~/.kube/reporting-dev-2-eks; kubectl config current-context"


# Git branch
parse_git_branch() {
    git branch 2>/dev/null | sed -n 's/^\* \(.*\)/[\1]/p'
}


# Git status emoji
git_status_emoji() {

    if git rev-parse --is-inside-work-tree &>/dev/null; then

    local status_text
    status_text=$(git status 2>/dev/null)

        if [[ -n "$(git status --porcelain 2>/dev/null)" ]]; then
            echo '❌'
        elif echo "$status_text" | grep -q "have diverged"; then
            echo '🔀'
        elif echo "$status_text" | grep -q "Your branch is ahead of"; then
            echo '📦'
        elif echo "$status_text" | grep -q "Your branch is behind"; then
            echo '⬇️'
        elif echo "$status_text" | grep -q "no upstream branch"; then
            echo '⬛'
        elif echo "$status_text" | grep -q "Your branch is up to date"; then
            echo '✅'
        else
            echo '⚠️'
        fi

    fi
}


# Function to update prompt elements
update_git_prompt() {
    GIT_STATUS_ICON=$(git_status_emoji)
    GIT_BRANCH=$(parse_git_branch)
}


# Register update function to run before each prompt
autoload -Uz add-zsh-hook
add-zsh-hook precmd update_git_prompt

# Enable colors
autoload -Uz colors && colors



setopt prompt_subst

# Define prompt using the dynamic vars
# export PS1="%{$fg[cyan]%}%n@%m%{$reset_color%} %{$fg[magenta]%}%~%{$reset_color%} ${GIT_STATUS_ICON}${GIT_BRANCH}%{$fg[magenta]%}%$%{$reset_color%} $ "
export PS1='%{$fg[cyan]%}%n@%m%{$reset_color%} %{$fg[magenta]%}%~%{$reset_color%} $(git_status_emoji)$(parse_git_branch) %{$fg[magenta]%}$ %{$reset_color%}'

## setup PATH
export PATH="$HOME/Library/Python/3.9/bin:$PATH"
export PATH="$HOME/Library/Python/3.11/bin:$PATH"
export PATH="$HOME/Library/Python/3.12/bin:$PATH"
export PATH="$HOME/Library/Python/3.13/bin:$PATH"


