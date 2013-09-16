
# scp .bashrc rootq@10.2.0.3:.bashrc
# rsync -av ec2:~/se/bitstarter /d/node
# find . -type f -print0 | xargs -0 chmod 0664; find . -type d -print0 | xargs -0 chmod 0775
# source "${HOME}/.bash_aliases"

# ---------------------------------------
# bash options
# ---------------------------------------
export LS_OPTIONS='--color=auto --group-directories-first'
PS1="\[\e]0;\w\a\]\n\[\e[32m\][\u@\h] [\d \t] [\!] \[\e[33m\]\w\[\e[0m\]\\n$ "
alias ls='ls $LS_OPTIONS -A'
alias ll='ls $LS_OPTIONS -lA'
alias rm='rm -i'
alias bashrc='head .bashrc -n 25'

# ---------------------------------------
# aliases
# ---------------------------------------
#alias vnc="vncserver :1 -geometry 1366x768 -depth 16"
#alias vnckill="vncserver -kill :1"

# ---------------------------------------
# path
# ---------------------------------------
#PATH=/cygdrive/c/xampp/mysql/bin/:$PATH
