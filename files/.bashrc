
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
alias bashh="nano ~/.bash_history"
alias bashe="nano ~/.eternal_history"

# ---------------------------------------
# aliases
# ---------------------------------------
#alias vnc="vncserver :1 -geometry 1600x900 -localhost"
#alias vnckill="vncserver -kill :1"

# ---------------------------------------
# paths
# ---------------------------------------
#PATH=/cygdrive/c/xampp/mysql/bin/:$PATH

# ---------------------------------------
# increase .bash_history limit
# http://mywiki.wooledge.org/BashFAQ/088
# ---------------------------------------
#HISTFILESIZE=400000000
#HISTSIZE=10000
#PROMPT_COMMAND="history -a"
#export HISTSIZE PROMPT_COMMAND
#shopt -s histappend

# ---------------------------------------
# https://github.com/startup-class/dotfiles/blob/master/.bashrc
# modified by removing most stuff
# ---------------------------------------
PROMPT_COMMAND="history -a;${PROMPT_COMMAND:+$PROMPT_COMMAND ; }"'echo -e `date "+%Y/%m/%d %T"`\\t$PWD\\t"$(history 1)" >> ~/.eternal_history'
shopt -s checkwinsize
shopt -s histappend

