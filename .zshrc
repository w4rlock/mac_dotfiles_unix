# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="/Users/u0166409/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
# ZSH_THEME="robbyrussell"
#ZSH_THEME="agnoster"

#ZSH_THEME="powerlevel10k/powerlevel10k"
ZSH_THEME="simpalt"
#POWERLEVEL9K_MODE="awesome-patched"
SIMPALT_PROMPT_SEGMENTS=(prompt_aws_profile prompt_status prompt_dir prompt_git)

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in ~/.oh-my-zsh/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to automatically update without prompting.
# DISABLE_UPDATE_PROMPT="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS=true

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in ~/.oh-my-zsh/plugins/*
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git zsh-z kubectl zsh-autosuggestions zsh-completions zsh-syntax-highlighting)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"
alias ls='ls++ -la'
alias cowsay='fortune | cowsay | lolcat'

alias kg="kubectl get"
alias k8s-nginx-ingress-list='kubectl ingress-nginx ingresses --all-namespaces'
alias k8s-nginx-ingress-logs='kubectl ingress-nginx logs -n ingress-nginx'
alias k8s-nginx-ingress-exec='kubectl ingress-nginx exec -i -n ingress-nginx --'
alias k8s-list-all-resources='kubectl api-resources --verbs=list -o name | xargs -n 1 kubectl get -o name'

alias aws-eks-clusters='aws eks list-clusters --region us-east-1 | jq -r ".clusters | .[]"'
alias aws-cf-export-list='aws cloudformation list-exports  --output table | tail -n +5'
alias aws-get-domain-names='aws apigateway get-domain-names | jq -r ".items | .[] | .domainName"'
alias aws-acm-ls="aws acm list-certificates --output text"

alias sls="SLS_DEBUG=* sls --verbose"
alias dotfiles='/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME'
alias rg-filename='rg -l'
alias fzf-preview='fzf --preview="bat --theme="OneHalfDark" --style=numbers,changes --color always {}"'


print-1(){ awk '{ print $1 }' }
print-2(){ awk '{ print $2 }' }
print-3(){ awk '{ print $3 }' }
only-az(){ sed "s/[^[:alnum:]_-]//g" }
git-status() {
git status -s \
 | fzf --no-sort --reverse \
	 --preview 'git diff --color=always {+2} | diff-so-fancy' \
	 --bind=ctrl-j:preview-down --bind=ctrl-k:preview-up \
	 --preview-window=right:80%:wrap
}


__fzf-zsh-fn() { fzf -1 -e --header-lines=1 -q "${1}" }

aws-cf-ls() { aws cloudformation describe-stacks | jq -r '.Stacks | .[] | .StackName' | fzf }
aws-iam-roles-ls-arn() { aws iam list-roles | jq -r '.Roles | .[] | .Arn' }
aws-iam-roles-ls-names() { aws iam list-roles | jq -r '.Roles | .[] | .RoleName' }
aws-profile-ls() { cat ~/.aws/credentials | grep --color=never -o '^\[[^]]*\]' }
aws-profile-set() { _prf=$(aws-profile-ls \
  | only-az \
  | fzf --header="--☁️  Aws - Profiles ☁️ --" -1 -e -q "${1}");

  [[ "${_prf}" != "" ]] && {
    export AWS_PROFILE=$_prf
    echo '[ ** ] - Fetching account info...'
    aws sts get-caller-identity
  }
}

aws-profile-assume-role() {
  _arg=${@:-''}
  _filter="AZAWS-${_arg}"
  _role=$(aws-iam-roles-ls-arn \
   | fzf --header="--☁️  Aws - Roles ☁️ --" -1 -e -q "${_filter}");

  [[ "${_role}" != "" ]] && {
    echo $_role
  }
}

aws-s3-ls(){ aws s3 ls | fzf -1 -e -q "$1" -m --preview="sleep .5 && aws s3 ls s3://{3}" | awk '{ print $3 }' }
aws-ecr-ls() { aws ecr describe-repositories  | jq -r '.repositories | .[] | .repositoryName' | fzf }

aws-s3-rm(){ echo "Empty Bucket"; aws-s3-ls "$@" | xargs -I{} echo "aws s3 rm s3://{}/ --recursive" }
aws-s3-rb(){ echo "Remove Empty Bucket"; aws-s3-ls "$@" | xargs -I{} echo "aws s3 rb s3://{}/ " }
aws-s3-mb(){ echo "Create New Bucket"; aws s3 mb s3://${1:?'bucket name is required'} }


vim-find(){ vim -p $(fzf -q $1 -m --preview="bat {}") }
vim-which(){ vim $(which $1) }


cat-which(){ bat $(which $1) }
cat-find(){ bat -p $(fzf -q "${1}" --preview="bat --theme='OneHalfDark' --style=numbers,changes --color always {}") }
code-view(){ cat-find $@ }



__k8s-ns(){ kubectl config set-context $(kubectl config current-context) --namespace=$1 }

k8s-ns(){ ns=$(kgns | __fzf-zsh-fn "$@" | awk '{ print  $1 }'); __k8s-ns $ns }
k8s-sh(){ pn=$(kgp  | __fzf-zsh-fn "$@" | print-1); echo "Shell pod \"${pn}\""; keti $pn -- /bin/sh }
k8s-pod-exec(){ pn=$(kgp  | __fzf-zsh-fn "$1" | print-1); shift; keti $pn -- $@ }

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"

PATH="/Users/u0166409/perl5/bin${PATH:+:${PATH}}"; export PATH;
PERL5LIB="/Users/u0166409/perl5/lib/perl5${PERL5LIB:+:${PERL5LIB}}"; export PERL5LIB;
PERL_LOCAL_LIB_ROOT="/Users/u0166409/perl5${PERL_LOCAL_LIB_ROOT:+:${PERL_LOCAL_LIB_ROOT}}"; export PERL_LOCAL_LIB_ROOT;
PERL_MB_OPT="--install_base \"/Users/u0166409/perl5\""; export PERL_MB_OPT;
PERL_MM_OPT="INSTALL_BASE=/Users/u0166409/perl5"; export PERL_MM_OPT;


export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git -E node_modules'
export FZF_DEFAULT_OPTS='--layout=reverse --color=16 --prompt=" " --cycle --no-info --bind=ctrl-j:preview-down --bind=ctrl-k:preview-up'

export PATH="/Users/u0166409/.pyenv/bin:$PATH"
export PATH="/Users/u0166409/.tools:$PATH"
export PATH="$HOME/Library/Python/3.7/bin:$PATH"
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"

#export NVM_DIR=~/.nvm
#source $(brew --prefix nvm)/nvm.sh
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
#source /usr/local/opt/nvm/nvm.sh

autoload -U compinit && compinit


#FZF REMOVE ZSH_HISTORY DUPLICATES
setopt EXTENDED_HISTORY
setopt HIST_EXPIRE_DUPS_FIRST
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt HIST_BEEP
#FZF REMOVE ZSH_HISTORY DUPLICATES


# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
prompt_context() {}


# ls colors support
export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

alias grep="grep --color=always"
alias egrep="egrep --color=always"
alias my-public-ip='curl ifconfig.co'
# ls colors support

# MAC OS KEYS
bindkey "[D" backward-word
bindkey "[C" forward-word

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

test -e ~/.dir_colors \
  && eval `dircolors -b ~/.dir_colors`

test -e "${HOME}/.iterm2_shell_integration.zsh" \
  && source "${HOME}/.iterm2_shell_integration.zsh" \
  || true

tmux_pwd() {
  local _pwd=$(tmux display -p -F "#{pane_current_path}" 2> /dev/null || pwd)
  _pwd=${_pwd/#$HOME/\~}
  if [[ "${_pwd}" == "~" ]]; then
    _pwd="${icon_home} ~/"
  else
    _pwd="${icon_folder_open} ${_pwd}"
  fi
  echo -n "${_pwd}"
}

iterm2_print_user_vars() {
  _pwd=$(tmux_pwd)
  iterm2_set_user_var 'pwd' $_pwd
}

if [[ -z "${TMUX}" ]]; then
  while true; do
    iterm2_print_user_vars
    sleep 2.5
  done &
fi

source ~/.fzf.zsh
source ~/.fzf-tab/fzf-tab.plugin.zsh

export PATH="/usr/local/bin:${PATH}"
export LC_ALL=en_US.UTF-8

_aws_restore_session() { . _aws-naranja --restore}
_aws_restore_session

aws-login() {  . _aws-naranja --login "${@}" }
aws-re-login() {  . _aws-naranja --re-login }
aws-logout() { . _aws-naranja --logout }

