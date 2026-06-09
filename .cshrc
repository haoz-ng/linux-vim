# ──────────────────────────────────────────
# Alias
# ──────────────────────────────────────────
# list
alias ll        "ls -alF --color=auto"

# prompt
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

# ──────────────────────────────────────────
# Timer (tcsh 6.20 compatible)
# ──────────────────────────────────────────

# --- File precmd: always overwrite ---
echo 'set _end_epoch = `date +%s`'                                                  >  ~/.csh_precmd.csh
echo 'set _end_str   = `date "+%Y-%m-%d %H:%M:%S"`'                                >> ~/.csh_precmd.csh
echo 'if ( $?_start_epoch ) then'                                                   >> ~/.csh_precmd.csh
echo '    @ _elapsed = $_end_epoch - $_start_epoch'                                 >> ~/.csh_precmd.csh
echo '    if ( $_elapsed >= 0 ) then'                                               >> ~/.csh_precmd.csh
echo '        @ _hh = $_elapsed / 3600'                                             >> ~/.csh_precmd.csh
echo '        @ _mm = ( $_elapsed % 3600 ) / 60'                                    >> ~/.csh_precmd.csh
echo '        @ _ss = $_elapsed % 60'                                               >> ~/.csh_precmd.csh
echo '        set _elapsed_str = "${_hh}h ${_mm}m ${_ss}s"'                         >> ~/.csh_precmd.csh
echo '        if ( $_hh == 0 && $_mm == 0 ) set _elapsed_str = "${_ss}s"'           >> ~/.csh_precmd.csh
echo '        if ( $_hh == 0 && $_mm != 0 ) set _elapsed_str = "${_mm}m ${_ss}s"'  >> ~/.csh_precmd.csh
echo '        echo ""'                                                              >> ~/.csh_precmd.csh
echo '        echo "Start: $_start_str  ->  End: $_end_str  |  Elapsed: ${_elapsed_str}"' >> ~/.csh_precmd.csh
echo '    endif'                                                                    >> ~/.csh_precmd.csh
echo 'endif'                                                                        >> ~/.csh_precmd.csh
echo '# Set start for NEXT command'                                                 >> ~/.csh_precmd.csh
echo 'set _start_epoch = `date +%s`'                                                >> ~/.csh_precmd.csh
echo 'set _start_str   = `date "+%Y-%m-%d %H:%M:%S"`'                              >> ~/.csh_precmd.csh

alias precmd 'source ~/.csh_precmd.csh'

# Initialize on first load of .cshrc
set _start_epoch = `date +%s`
set _start_str   = `date "+%Y-%m-%d %H:%M:%S"`
