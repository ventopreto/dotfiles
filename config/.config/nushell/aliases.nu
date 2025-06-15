alias ne = code ~/.config/nushell/config.nu
alias ae = code ~/.config/nushell/aliases.nu
alias ll = ls -lh
alias gs = git status
alias ga = git add .
alias gp = git push

# Alias para iniciar o tmux
alias ts = tmux new-session -A -s main
alias tks = tmux kill-server
alias eipb = cd ~/workspace/eagle-ip-backend

# Alias rails
alias bers = bundle exec rails s
alias berc = bundle exec rails c

alias mswag = rake rswag:specs:swaggerize
alias dc = docker compose
alias dcewb = dc exec web bash
alias da = docker attach

# Git Aliases
alias gs = git status
alias ga = git add .
def gc [msg: string] { git commit -m $msg }
alias gp = git push
alias gst = git stash
alias gstp = git stash pop
alias gsta = git stash apply
alias gsh = git show
alias gshw = git show
alias gshow = git show
alias gi = code .gitignore
alias gcm = git ci -m
alias gcim = git ci -m
alias gci = git ci
alias gco = git co
alias gcp = git cp
alias ga = git add -A
alias guns = git unstage
alias gunc = git uncommit
alias gm = git merge
alias gr = git rebase
alias gra = git rebase --abort
alias grc = git rebase --continue
alias gbi = git rebase --interactive
alias gl = git log --graph --date=format:"%d/%m/%y" --pretty=format:'%C(auto)%h %ad %s'
alias co = git co
alias gf = git fetch
alias gfch = git fetch
alias gd = git diff
alias gds = git diff --staged
alias gb = git b
alias gbd = git b -D -w
alias gdc = git diff --cached -w
alias gpub = grb publish
alias gtr = grb track
alias gpl = git pull
alias gplr = git pull --rebase
alias gps = git push
alias gpsh = git push -u origin `git rev-parse --abbrev-ref HEAD`
alias gnb = git nb  # new branch aka checkout -b
alias grs = git reset
alias grsh = git reset --hard
alias gcln = git clean
alias gclndf = git clean -df
alias gclndfx = git clean -dfx
alias gt = git t

alias killcode = pkill -f 'code'
alias killpuma = pkill -f 'puma'
