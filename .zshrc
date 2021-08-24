# If you come from bash you might have to change your $PATH.

#
# export PATH=$HOME/bin:/usr/local/bin:$PATH

source $HOME/.tmux.style

# Path to your oh-my-zsh installation.
export ZSH="${HOME}/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="simpalt"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
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
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# Caution: this setting can cause issues with multiline prompts (zsh 5.7.1 and newer seem to work)
# See https://github.com/ohmyzsh/ohmyzsh/issues/5765
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
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
SIMPALT_PROMPT_SEGMENTS=(
  #prompt_preffix
  #prompt_aws_profile
  prompt_status
  prompt_dir
  prompt_git
  #prompt_node_version
)


plugins=(git
  zsh-z
  fzf
  kubectl
  zsh-autosuggestions
  zsh-completions
  zsh-syntax-highlighting
)


source $ZSH/oh-my-zsh.sh


source ~/.zplug/init.zsh
zplug 'wfxr/forgit'
# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load --verbose


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
export LC_ALL=en_US.UTF-8


# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#alias ls='ls++ -la'
#alias ls='colorls -ha'
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

bluetooth-connect() {
  mac=$(bt-device -l | fzf --header-lines=1 | awk '{ print substr($NF, 2, length($NF)-2) }');
  echo -e "connect ${mac} \nquit" | bluetoothctl
}

bluetooth-disconnect() {
  mac=$(bt-device -l | fzf --header-lines=1 -1 | awk '{ print substr($NF, 2, length($NF)-2) }');
  echo -e "disconnect ${mac} \nquit" | bluetoothctl
}

code-sh() {
  vim ${1}.sh
  test -e ${1}.sh && chmod +x ${1}.sh
}


docker-sh() { id=$(docker ps  | __fzf-zsh-fn "$@" | awk '{ print $1 }'); [[ "${id}" != "" ]] && docker exec -ti $id bash }
docker-stop() { id=$(docker ps -a  | __fzf-zsh-fn "$@" | awk '{ print $1 }'); [[ "${id}" != "" ]] && docker stop $id && docker rm $id}
docker-logs() { id=$(docker ps -a | __fzf-zsh-fn "$@" | awk '{ print $1 }'); [[ "${id}" != "" ]] && docker logs -f $id }
docker-stop-all() { docker stop $(docker ps -qa) && docker rm $(docker ps -qa) }
docker-run() { img=$(docker images  | __fzf-zsh-fn "$@" | awk '{ print $1 }'); [[ "${img}" != "" ]] && docker run -it --rm  -p 8080:8080 $img }

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


export FZF_DEFAULT_COMMAND='fd --type file --follow --hidden --exclude .git -E node_modules'
export FZF_DEFAULT_OPTS='--layout=reverse --color=16 --prompt=" " --cycle --no-info --bind=ctrl-j:preview-down --bind=ctrl-k:preview-up'


#export NVM_DIR="$HOME/.nvm"
#[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="${HOME}/.tools:$PATH"
export PATH="${HOME}/.tools/diff-so-fancy:$PATH"
export PATH="${HOME}/.tools/git-fuzzy/bin:$PATH"

export AWESOME_WM_DIR="${HOME}/.config/awesome"
export AWESOME_WM_THEME_DIR="${HOME}/.config/awesome/themes/dremora"

# replaced for asdf python
# export PATH="${HOME}/.pyenv/bin:$PATH"
# eval "$(pyenv init -)"
# eval "$(pyenv virtualenv-init -)"


source  $HOME/.asdf/asdf.sh
# append completions to fpath
fpath=(${ASDF_DIR}/completions $fpath)
# initialise completions with ZSH's compinit
autoload -Uz compinit
compinit


_aws_restore_session() { . aws-corp-login --restore}
#_aws_restore_session
aws-login() {  . aws-corp-login --login "${@}" }
aws-re-login() {  . aws-corp-login --re-login }
aws-logout() { . aws-corp-login --logout }


export PATH=/Users/u0166409/.asdf/shims:/Users/u0166409/.asdf/bin:/Users/u0166409/.tools/git-fuzzy/bin:/Users/u0166409/.tools/diff-so-fancy:/Users/u0166409/.tools:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:/Users/u0166409/.local/bin:/Users/u0166409/.local/bin:~/Library/Python/3.8/bin

alias ls='colorls -a --light --sd --sf --group-directories-first'
tree(){ depth=${1:-2}; ls --tree=$depth; }
alias ssh-add-simtlix='eval $(ssh-agent) && ssh-add ~/.ssh/ssh_erosal_simtlix_rsa'

alias dotfiles='git --git-dir=${HOME}/.dotfiles/ --work-tree=${HOME}'

