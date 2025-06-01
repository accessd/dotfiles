alias vim="nvim"
alias v="nvim"
alias dps="docker ps"
alias g="git"

# ruby
alias bi="bundle install"
alias be="bundle exec"
alias bu="bundle update"
alias bo="bundle open"
alias rk="be rake"
alias rs="bin/rails s"
alias rp="be rubocop"

alias mc="mc --nosubshell"

alias k="kubectl"


# From YADR

# PS
alias psa="ps aux"
alias psg="ps aux | grep "
alias psr='ps aux | grep ruby'

# Moving around
alias cdb='cd -'

# Show human friendly numbers and colors
alias df='df -h'
alias ll='ls -alGh'
alias ls='ls -Gh'
alias du='du -h -d 2'

# show me files matching "ls grep"
alias lsg='ll | grep'

# vimrc editing
alias ve='nvim ~/.vimrc'

# zsh profile editing
alias ze='nvim ~/.zshrc'
alias zr='source ~/.zshrc'

# Don't try to glob with zsh so you can do
# stuff like ga *foo* and correctly have
# git add the right stuff
alias git='noglob git'

# Git Aliases
alias gs='git status'
alias gstsh='git stash'
alias gst='git stash'
alias gsp='git stash pop'
alias gsa='git stash apply'
alias gsh='git show'
alias gshw='git show'
alias gshow='git show'
alias gi='vim .gitignore'
alias gcm='git ci -m'
alias gcim='git ci -m'
alias gci='git ci'
alias gco='git co'
alias gcp='git cp'
alias ga='git add -A'
alias guns='git unstage'
alias gunc='git uncommit'
alias gm='git merge'
alias gms='git merge --squash'
alias gam='git amend --reset-author'
alias grv='git remote -v'
alias grr='git remote rm'
alias grad='git remote add'
alias gr='git rebase'
alias gra='git rebase --abort'
alias ggrc='git rebase --continue'
alias gbi='git rebase --interactive'
alias gl='git l'
alias glg='git l'
alias glog='git l'
alias co='git co'
alias gf='git fetch'
alias gfch='git fetch'
alias gd='git diff'
alias gb='git b'
alias gbd='git b -D -w'
alias gdc='git diff --cached -w'
alias gpub='grb publish'
alias gtr='grb track'
alias gpl='git pull'
alias gplr='git pull --rebase'
alias gp='git push'
alias gps='git push'
alias gpsh='git push'
alias gnb='git nb' # new branch aka checkout -b
alias grs='git reset'
alias grsh='git reset --hard'
alias gcln='git clean'
alias gclndf='git clean -df'
alias gclndfx='git clean -dfx'
alias gsm='git submodule'
alias gsmi='git submodule init'
alias gsmu='git submodule update'
alias gt='git t'
alias gbg='git bisect good'
alias gbb='git bisect bad'

# Common shell functions
alias less='less -r'
alias tf='tail -f'
alias l='less'
alias lh='ls -alt | head' # see the last modified files
alias cl='clear'

alias rdm='rake db:migrate'
alias rdmr='rake db:migrate:redo'

alias grb='git recent-branches'

# Override rm -i alias which makes rm prompt for every action
alias rm='nocorrect rm'


# git
alias last_tag="gt | tail -1"
unalias grh 2>/dev/null
alias repush="g smart-pull && g push"
function grh () { git rebase -i HEAD~$1 }
function add_tag () { git tag -a $1 -m "Release $1" }
alias gcr="ga;gc -m 'fix';grh 2"
alias gpr="git smart-pull"
alias fixpush="ga && gcm 'fix' && gp"
