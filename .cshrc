# ──────────────────────────────────────────
# Alias
# ──────────────────────────────────────────
# list
alias ll        "ls -alF --color=auto"

# prompt
setenv LANG en_US.UTF-8
setenv LC_ALL en_US.UTF-8

# ==================== Customizable Settings ===================
set PROMPT_LABEL = "Haoz"
# set PROMPT_ICON  = `printf "\xe6\x84\x9b"`       # 愛
set PROMPT_ICON  = `printf "\xf0\x9f\xa7\xa2"`   # 🧢 cap emoji

set COLOR_HOST  = "1;32"
set COLOR_USER  = "1;36"
set COLOR_LABEL = "1;36"
set COLOR_ICON  = "38;5;204"
set COLOR_PATH  = "1;36"
set COLOR_DIR   = "1;32"
set COLOR_ARROW = "1;36"
set COLOR_RESET = "0"

# Background colors (256-color codes)
set BG_ICON  = "48;5;236"
set BG_INFO  = "48;5;234"
set BG_DIR   = "48;5;235"
# ==============================================================

alias cwdcmd ' \
  if ( "$cwd" == "$HOME" ) then \
    set prompt = "\n%{\e]2;%~\a%}[%{\033[${COLOR_ICON};${BG_ICON}m%}${PROMPT_ICON}%{\033[${COLOR_RESET}m%}][%{\033[${COLOR_HOST};${BG_INFO}m%}%m%{\033[${COLOR_RESET}m%}:%{\033[${COLOR_USER};${BG_INFO}m%}%n%{\033[${COLOR_RESET}m%}:%{\033[${COLOR_LABEL};${BG_INFO}m%}${PROMPT_LABEL}%{\033[${COLOR_RESET}m%}][%{\033[${COLOR_HOST};${BG_DIR}m%}~%{\033[${COLOR_RESET}m%}]\n%{\033[${COLOR_ARROW}m%}  --> %{\033[${COLOR_RESET}m%}%s "; \
  else \
    set path_without_last = `dirname "$cwd"`; \
    set last_dir = `basename "$cwd"`; \
    if ( "$path_without_last" == "$HOME" ) set path_without_last = "~"; \
    set prompt = "\n%{\e]2;%~\a%}[%{\033[${COLOR_ICON};${BG_ICON}m%}${PROMPT_ICON}%{\033[${COLOR_RESET}m%}][%{\033[${COLOR_HOST};${BG_INFO}m%}%m%{\033[${COLOR_RESET}m%}:%{\033[${COLOR_USER};${BG_INFO}m%}%n%{\033[${COLOR_RESET}m%}:%{\033[${COLOR_LABEL};${BG_INFO}m%}${PROMPT_LABEL}%{\033[${COLOR_RESET}m%}][%{\033[${COLOR_PATH};${BG_DIR}m%}$path_without_last/%{\033[${COLOR_RESET}m%}%{\033[${COLOR_DIR};${BG_DIR}m%}$last_dir%{\033[${COLOR_RESET}m%}]\n%{\033[${COLOR_ARROW}m%}  --> %{\033[${COLOR_RESET}m%}%s "; \
  endif'
cwdcmd



alias gf 'sh -c '"'"'kw=$1; shift; cwd=$(pwd); grep -rn --color=never "$kw" "$@" | perl -pe "s|^(\./)|$cwd/|; s|^([^:]+)|\033[36m\$1\033[0m|; s|:([0-9]+):|\033[0m:\033[32m\$1\033[0m:|; s|\Q$kw\E|\033[31m\$&\033[0m|g"'"'"' -- \!*'

alias gvim     'gvim \!* &'
alias g        'gvim \!* &'
alias gdiff    'gvimdiff'

# svn bind
# Add to ~/.cshrc

# SVN Status with colors (display only)
alias stt 'svn status | awk '\''{if($1=="M")print"\033[33m"$0"\033[0m";else if($1=="A")print"\033[32m"$0"\033[0m";else if($1=="D")print"\033[31m"$0"\033[0m";else if($1=="?")print"\033[36m"$0"\033[0m";else if($1=="C")print"\033[1;31m"$0"\033[0m";else if($1=="!")print"\033[35m"$0"\033[0m";else print$0;}'\'''

# SVN Diff with colors (display only)
alias sdiff 'svn diff \!:1 | awk '\''{if($0~/^---/||$0~/^-[^-]/)print"\033[31m"$0"\033[0m";else if($0~/^\+\+\+/||$0~/^\+[^+]/)print"\033[32m"$0"\033[0m";else if($0~/^@@/)print"\033[36m"$0"\033[0m";else print$0;}'\'''

# SVN Update with colors (display only)
alias sup 'svn up \!:* | awk '\''{if($1=="U")print"\033[33m"$0"\033[0m";else if($1=="A")print"\033[32m"$0"\033[0m";else if($1=="D")print"\033[31m"$0"\033[0m";else if($1=="G")print"\033[36m"$0"\033[0m";else if($1=="C")print"\033[1;31m"$0"\033[0m";else if($0~/^At revision/)print"\033[1;32m"$0"\033[0m";else if($0~/^Updated to revision/)print"\033[1;32m"$0"\033[0m";else print$0;}'\'''

# SVN Info with colors (display only)
alias sinfo 'svn info \!:* | awk '\''{if($0~/^Path:/)print"\033[1;36m"$0"\033[0m";else if($0~/^URL:/)print"\033[1;34m"$0"\033[0m";else if($0~/^Repository Root:/)print"\033[34m"$0"\033[0m";else if($0~/^Revision:/)print"\033[1;32m"$0"\033[0m";else if($0~/^Last Changed Rev:/)print"\033[32m"$0"\033[0m";else if($0~/^Last Changed Author:/)print"\033[33m"$0"\033[0m";else if($0~/^Last Changed Date:/)print"\033[35m"$0"\033[0m";else if($0~/^Node Kind:/)print"\033[36m"$0"\033[0m";else print$0;}'\'''


