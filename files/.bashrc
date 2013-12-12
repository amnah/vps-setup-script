
# scp .bashrc rootq@10.2.0.3:.bashrc
# source "${HOME}/.bash_aliases"
# rsync -av ec2:~/se/bitstarter /d/node
# tar -czhpf data.tar.gz /data --exclude "/data/sites/xxx" --exclude "vendor" --exclude "/data/phpMyAdmin*"
# find / -name "*.sock"
# find . -type f -print0 | xargs -0 chmod 0644; find . -type d -print0 | xargs -0 chmod 0755

# ---------------------------------------
# bash options
# ---------------------------------------
export LS_OPTIONS='--color=auto --group-directories-first'
PS1="\[\e]0;\w\a\]\n\[\e[32m\][\u@\h] [\d \t] [\!] \[\e[33m\]\w\[\e[0m\]\\n$ "
alias ls='ls $LS_OPTIONS -hA'
alias ll='ls $LS_OPTIONS -lhA'
alias rm='rm -i'
alias bashrc='head .bashrc -n 25'

# ---------------------------------------
# aliases
# ---------------------------------------
#alias vnc="vncserver :1 -geometry 1600x900 -depth 16"
#alias vnckill="vncserver -kill :1"

# ---------------------------------------
# path
# ---------------------------------------
#PATH=/cygdrive/c/xampp/mysql/bin/:$PATH

# ---------------------------------------
# increase .bash_history limit
# http://mywiki.wooledge.org/BashFAQ/088
# ---------------------------------------
HISTFILESIZE=400000000
HISTSIZE=10000
PROMPT_COMMAND="history -a"
export HISTSIZE PROMPT_COMMAND
shopt -s histappend
