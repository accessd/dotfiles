alias v="vim ."
alias t="terraform"
alias dps="docker ps"

# git
alias last_tag="gt | tail -1"
unalias grh 2>/dev/null
alias repush="g smart-pull && g push"
function grh () { git rebase -i HEAD~$1 }
function add_tag () { git tag -a $1 -m "Release $1" }
alias gcr="ga;gc -m 'fix';grh 2"
alias gpr="g smart-pull"
alias fixpush="ga && gcm 'fix' && gp"

# ruby
alias bi="bundle install"
alias be="bundle exec"
alias bu="bundle update"
alias bo="bundle open"
alias rk="be rake"
alias rs="bin/rails s"
alias rp="be rubocop"

# deploy
function deploy_tag () { TAG=v$1 DEPLOY_ENV=production make }
alias deploy_last_tag="last_tag | deploy_tag"
