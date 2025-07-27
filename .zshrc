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
alias dc="docker-compose"
alias d="docker"

alias aws-int="okta-awscli -v --profile integration --okta-profile integration; export AWS_PROFILE=integration;"
alias aws-core="okta-awscli -v --profile core --okta-profile core; export AWS_PROFILE=core;"
alias aws-set=". ~/cli_auth.sh;"
alias aws-check="aws sts get-caller-identity;"


# Kubernetes aliases converted to functions with prod guard
function kube() { kube_prod_guard "$@" && command kubectl $(echo "$@" | sed 's/ -p//g'); }
function kube-check() { kube_prod_guard "$@" && command kubectl config current-context; }
function kube-prod1() { export KUBECONFIG=~/.kube/reporting-prod-1; kube_prod_guard "$@" && command kubectl config current-context; }
function kube-prod2() { export KUBECONFIG=~/.kube/reporting-prod-2; kube_prod_guard "$@" && command kubectl config current-context; }
function kube-dev2() { export KUBECONFIG=~/.kube/reporting-dev-2-eks; kube_prod_guard "$@" && command kubectl config current-context; }
function kube-gdev() { export KUBECONFIG=~/.kube/google-dev; kube_prod_guard "$@" && command kubectl config current-context; }
function kube-spaces() { kube_prod_guard "$@" && command kubectl get namespaces; }
function kube-pods() { kube_prod_guard "$@" && command kubectl get pods -n $(echo "$@" | sed 's/ -p//g'); }
function kube-pods-by-node() {
    kube_prod_guard "$@" &&
    for node in $(command kubectl get nodes -o name | cut -d/ -f2); do
        echo -e "\n### Pods on node: $node ###"
        command kubectl get pods --all-namespaces --field-selector spec.nodeName=$node
    done
}


# alias's
alias k="kube"
alias k-check="kube-check"
alias k-prod1="kube-prod1"
alias k-prod2="kube-prod2"
alias k-dev2="kube-dev2"
alias k-gdev="kube-gdev"
alias k-spaces="kube-spaces"
alias k-pods="kube-pods"
alias k-pn="kube-pods-by-node"

# Shared guard and display
function kube_prod_guard() {
  local bypass_prompt="false"
  local context
  
  # Check for -p flag in arguments
  for arg in "$@"; do
    if [[ "$arg" == "-p" ]]; then
      bypass_prompt="true"
      break
    fi
  done
  
  context="$(command kubectl config current-context 2>/dev/null || echo "unknown")"
  echo -e "\033[1;34m[Context: $context]\033[0m"

  if [[ "$context" =~ [Pp][Rr][Oo][Dd] ]]; then
    echo -e "\033[1;31mWARNING: You are connected to a PROD Kubernetes context: $context\033[0m"
    
    if [[ "$bypass_prompt" == "true" ]]; then
      echo "Bypassing confirmation due to -p flag"
    else
      echo -n "Are you sure you want to continue? (y/N): "
      read confirm
      if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        echo "Aborted."
        return 1
      fi
    fi
  fi
  return 0
}

# Wrap kube commands
function kubectl()   { kube_prod_guard "$@" && command kubectl $(echo "$@" | sed 's/ -p//g'); }
function kubectx()   { kube_prod_guard "$@" && command kubectx $(echo "$@" | sed 's/ -p//g'); }
function kubens()    { kube_prod_guard "$@" && command kubens $(echo "$@" | sed 's/ -p//g'); }
function k9s()       { kube_prod_guard "$@" && command k9s $(echo "$@" | sed 's/ -p//g'); }
function helm()      { kube_prod_guard "$@" && command helm $(echo "$@" | sed 's/ -p//g'); }
function skaffold()   { kube_prod_guard "$@" && command skaffold $(echo "$@" | sed 's/ -p//g'); }
function flux()       { kube_prod_guard "$@" && command flux $(echo "$@" | sed 's/ -p//g'); }
function argo()       { kube_prod_guard "$@" && command argo $(echo "$@" | sed 's/ -p//g'); }
function istioctl()   { kube_prod_guard "$@" && command istioctl $(echo "$@" | sed 's/ -p//g'); }
function kustomize()  { kube_prod_guard "$@" && command kustomize $(echo "$@" | sed 's/ -p//g'); }
function velero()     { kube_prod_guard "$@" && command velero $(echo "$@" | sed 's/ -p//g'); }
function telepresence() { kube_prod_guard "$@" && command telepresence $(echo "$@" | sed 's/ -p//g'); }
function stern()      { kube_prod_guard "$@" && command stern $(echo "$@" | sed 's/ -p//g'); }
function kubeseal()   { kube_prod_guard "$@" && command kubeseal $(echo "$@" | sed 's/ -p//g'); }



# Function to show kubernetes shortcuts (like alias but for functions)
function k-help() {
    echo "=== Kubernetes Functions & Shortcuts ==="
    echo "k                  - kubectl with prod guard"
    echo "k-spaces           - kubectl get namespaces"
    echo "k-pods NAMESPACE   - kubectl get pods -n NAMESPACE"
    echo "k-pods-by-node     - show pods grouped by node"
    echo "kube-check         - show current context"
    echo "kube-prod1         - switch to prod-1 context"
    echo "kube-prod2         - switch to prod-2 context"  
    echo "kube-dev2          - switch to dev-2 context"
    echo ""
    echo "Add -p flag to bypass prod confirmation:"
    echo "Example: k-spaces -p, kube-check -p, kubectl get pods -p"
    echo ""
    echo "Other protected commands:"
    echo "kubectl, kubectx, kubens, k9s, helm, flux, argo,"
    echo "istioctl, kustomize, velero, telepresence, stern, kubeseal"
}


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
export PATH="$(gcloud info --format='value(installation.sdk_root)')/bin:$PATH"


