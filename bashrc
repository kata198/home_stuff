#
# ~/.bashrc
#


# If not running interactively, don't do anything
[[ $- != *i* ]] && return

FROM_BASHRC=1 source ~/.bash_profile
alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '

export PYTHONSTARTUP="$HOME/.pystartup"
