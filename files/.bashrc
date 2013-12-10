
# scp .bashrc rootq@10.2.0.3:.bashrc
# source "${HOME}/.bash_aliases"
# scp .bashrc rootq@10.2.0.3:.bashrc
# rsync -av ec2:~/se/bitstarter /d/node
# tar -czhpf data.tar.gz /data --exclude "/data/sites/xxx" --exclude "vendor" --exclude "/data/phpMyAdmin*"
# find / -name "*.sock"

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
