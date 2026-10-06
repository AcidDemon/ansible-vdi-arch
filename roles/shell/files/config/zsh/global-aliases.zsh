# Global aliases: `ls G foo` expands to `ls | grep foo`

alias -g G='| grep'
alias -g Gi='| grep -i'
alias -g L='| less'
alias -g H='| head'
alias -g T='| tail'
alias -g S='| sort'
alias -g U='| sort -u'
alias -g C='| wc -l'
alias -g X='| xargs'

alias -g J='| jq'
alias -g JL='| jq -C | less -R'

alias -g NF='2>/dev/null'
alias -g NE='2>&1'
alias -g DN='>/dev/null 2>&1'

alias -g CA='2>&1 | cat -A'
alias -g CP='| clipboard'
