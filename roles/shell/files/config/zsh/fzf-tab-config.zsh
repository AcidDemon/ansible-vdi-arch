# Disable sort when completing options with `_eza`
zstyle ':completion:complete:*:options' sort false

zstyle ':fzf-tab:complete:*:options' fzf-preview ''

# Disable preview for command/subcommand completions (git, systemctl, docker, etc.)
zstyle ':fzf-tab:complete:git:*' fzf-preview ''
zstyle ':fzf-tab:complete:docker:*' fzf-preview ''
zstyle ':fzf-tab:complete:podman:*' fzf-preview ''
zstyle ':fzf-tab:complete:kubectl:*' fzf-preview ''
zstyle ':fzf-tab:complete:systemctl:*' fzf-preview ''
zstyle ':fzf-tab:complete:journalctl:*' fzf-preview ''
zstyle ':fzf-tab:complete:ssh:*' fzf-preview ''
zstyle ':fzf-tab:complete:scp:*' fzf-preview ''
zstyle ':fzf-tab:complete:rsync:*' fzf-preview ''
zstyle ':fzf-tab:complete:cargo:*' fzf-preview ''
zstyle ':fzf-tab:complete:go:*' fzf-preview ''
zstyle ':fzf-tab:complete:npm:*' fzf-preview ''
zstyle ':fzf-tab:complete:pnpm:*' fzf-preview ''
zstyle ':fzf-tab:complete:yarn:*' fzf-preview ''
zstyle ':fzf-tab:complete:pip:*' fzf-preview ''
zstyle ':fzf-tab:complete:brew:*' fzf-preview ''
zstyle ':fzf-tab:complete:pacman:*' fzf-preview ''
zstyle ':fzf-tab:complete:apt:*' fzf-preview ''

# Only show directories for cd command
zstyle ':completion:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*' file-patterns '*(/):directories'

# Default preview for files and directories — wrapper handles dirs, images, and all file types
zstyle ':fzf-tab:complete:*:*' fzf-preview 'fzf-preview-wrapper $realpath 2>/dev/null'

# Preview for processes (kill, ps, etc)
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-preview '[[ $group == "[process ID]" ]] && ps -p $word -o command='
zstyle ':fzf-tab:complete:(kill|ps):argument-rest' fzf-flags '--preview-window=down:3:wrap'

# Preview for environment variables
zstyle ':fzf-tab:complete:(-command-|-parameter-|-brace-parameter-|export|unset|expand):*' fzf-preview 'echo ${(P)word}'

# Preview for git
zstyle ':fzf-tab:complete:git-(add|diff|restore):*' fzf-preview 'if [[ -e ${realpath:-$word} ]]; then git diff -- ${realpath:-$word} | delta; elif git rev-parse -q --verify "$word^{commit}" >/dev/null 2>&1; then git diff $word | delta; fi'
zstyle ':fzf-tab:complete:git-log:*' fzf-preview 'git log --color=always $word'
zstyle ':fzf-tab:complete:git-show:*' fzf-preview 'git show --color=always $word | delta'
zstyle ':fzf-tab:complete:git-checkout:*' fzf-preview 'git log --color=always $word'

# Give a preview when completing `man`
zstyle ':fzf-tab:complete:(man|tldr):argument-rest' fzf-preview '[[ $group == "manual page" ]] && man $word || tldr $word'

# Preview for systemctl
zstyle ':fzf-tab:complete:systemctl-*:*' fzf-preview 'SYSTEMD_COLORS=1 systemctl status $word'

# Switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

# two args, not one string
zstyle ':fzf-tab:*' fzf-flags '--preview-window=right:50%' '--bind=tab:down,shift-tab:up,change:top'
zstyle ':fzf-tab:*' fzf-min-height 20

zstyle ':fzf-tab:*' single-group ''

zstyle ':fzf-tab:*' prefix ''