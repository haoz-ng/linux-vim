alias ll        "ls -alF --color=auto"

alias cwdcmd ' \
  if ( "$cwd" == "$HOME" ) then \
    set prompt = "\n[%T]%{\e]2;%~\a%}[%m:%n][%{\033[1;32m%}~%{\033[0m%}]\n%{\033[1;36m%}Haoz %#%#%{\033[0m%}%s "; \
  else \
    set path_without_last = `dirname "$cwd"`; \
    set last_dir = `basename "$cwd"`; \
    if ( "$path_without_last" == "$HOME" ) set path_without_last = "~"; \
    set prompt = "\n[%T]%{\e]2;%~\a%}[%m:%n][%{\033[1;36m%}$path_without_last/%{\033[0m%}%{\033[1;32m%}$last_dir%{\033[0m%}]\n%{\033[1;36m%}Haoz %#%#%{\033[0m%}%s "; \
  endif'
cwdcmd

alias gf "grep -rn"

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
alias sup 'svn update \!:* | awk '\''{if($1=="U")print"\033[33m"$0"\033[0m";else if($1=="A")print"\033[32m"$0"\033[0m";else if($1=="D")print"\033[31m"$0"\033[0m";else if($1=="G")print"\033[36m"$0"\033[0m";else if($1=="C")print"\033[1;31m"$0"\033[0m";else if($0~/^At revision/)print"\033[1;32m"$0"\033[0m";else if($0~/^Updated to revision/)print"\033[1;32m"$0"\033[0m";else print$0;}'\'''

# SVN Info with colors (display only)
alias sinfo 'svn info \!:* | awk '\''{if($0~/^Path:/)print"\033[1;36m"$0"\033[0m";else if($0~/^URL:/)print"\033[1;34m"$0"\033[0m";else if($0~/^Repository Root:/)print"\033[34m"$0"\033[0m";else if($0~/^Revision:/)print"\033[1;32m"$0"\033[0m";else if($0~/^Last Changed Rev:/)print"\033[32m"$0"\033[0m";else if($0~/^Last Changed Author:/)print"\033[33m"$0"\033[0m";else if($0~/^Last Changed Date:/)print"\033[35m"$0"\033[0m";else if($0~/^Node Kind:/)print"\033[36m"$0"\033[0m";else print$0;}'\'''

