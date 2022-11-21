#!/bin/bash
# Based on:
# https://github.com/manofthelionarmy/vimFzf-Rg/blob/master/myfunctions.sh
#
# To run this script you need to install a set of tools
# sudo apt-get install ripgrep fzf bat git
#
# To be able to use all functions some optional tools come in handy. They take some time to setup properly. So, please google :-)
# Neovim (lua-based version of vim)
# Lunarvim (Integrated Development Environment based on Neovim)
# Tmux (Terminal Multiplexer)
#
# Default opts that set the dracula fzf color theme
#export FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --height 80% --layout=reverse --border'
export FZF_DEFAULT_OPTS='--prompt="🔭 " --height 80% --layout=reverse --border'

# Default command
export FZF_DEFAULT_COMMAND='rg --files --no-ignore --hidden --follow --glob "!.git/" --glob "!node_modules/" --glob "!vendor/" --glob "!undo/" --glob "!plugged/"'

# Preview them using bat
export BAT_THEME='gruvbox-dark'

# TODO: make a function that does fzf at root of git project
#function gitHelper {
# # check if we are in a git project
# # https://stackoverflow.com/a/2180367
# git rev-parse --git-dir 2> /dev/null
#
# # this shows the directory for the root of the git local repo
# git rev-parse --show-toplevel | echo . | fd -t f | fzf;
#}

function displayFZFFiles {
    echo $(fzf --preview 'bat --theme=gruvbox-dark --color=always --style=header,grid --line-range :400 {}')
}

function nvimGoToFiles {
    nvimExists=$(which nvim)
    if [ -z "$nvimExists" ]; then
      return;
    fi;

    selection=$(displayFZFFiles);
    if [ -z "$selection" ]; then
        return;
    else
        nvim $selection;
    fi;
}

function vimGoToFiles {
    vimExists=$(which vim)
    if [ -z "$vimExists" ]; then
      return;
    fi;

    selection=$(displayFZFFiles);
    if [ -z "$selection" ]; then
        return;
    else
        if [ "$TERM" != "xterm-256color" ]; then
            TERM="xterm-256color"
        fi
        vim $selection;
    fi;
}

function displayRgPipedFzf {
    echo $(rg . -n --glob '!.git/' --glob '!vendor/' --glob '!node_modules/' | fzf -d ':' -n 2.. --ansi --no-sort --preview 'bat --style=numbers --color=always --highlight-line {2} {1}' --preview-window +{2}-5)
}

function nvimGoToLine {
    nvimExists=$(which nvim)
    if [ -z "$nvimExists" ]; then
      return;
    fi
    selection=$(displayRgPipedFzf)
    if [ -z "$selection" ]; then
      return;
    else
        filename=$(echo $selection | cut -d: -f1)
        line=$(echo $selection | cut -d: -f2)
        nvim $(printf "+%s %s" $line $filename) +"normal zz^";
    fi
}

function vimGoToLine {
    vimExists=$(which vim)
    if [ -z "$vimExists" ]; then
      return;
    fi
    selection=$(displayRgPipedFzf)
    if [ -z "$selection" ]; then
      return;
    else
        filename=$(echo $selection | awk -F ':' '{print $1}')
        line=$(echo $selection | awk -F ':' '{print $2}')
        if [ "$TERM" != "xterm-256color" ]; then
            TERM="xterm-256color";
        fi;
        vim $(printf "+%s %s" $line $filename) +"normal zz";
    fi
}

function fdFzf {
	fdExists=$(which fd)
	if [ -z "$fdExists" ]; then
					return;
	else
    if [ "$(pwd)" = "$HOME" ]; then
      goTo=$(fd -t d -d 1 . | fzf)
      if [ -z "$goTo" ]; then
        return;
      else
        cd $goTo
        return;
      fi
    fi
    goTo=$(fd -t d . | grep -vE '(node_modules)' | fzf)
    if [ -z "$goTo" ]; then
      return;
    else
      cd $goTo
    fi
	fi
}

function tmuxAttachFZF {
  tmuxExists=$(which tmux)
  if [ -z "$tmuxExists" ]; then
    return;
  fi

  sessions=$(tmux ls)
  if [ -z "$sessions" ]; then
    return;
  fi

  selectedSession=$(echo $sessions | awk -F ':' '{print $1}' | fzf)
  if [ -z "$selectedSession" ]; then
    return;
  fi
  tmux attach -t $selectedSession;
}

function tmuxKillFZF {
  tmuxExists=$(which tmux)
  if [ -z "$tmuxExists" ]; then
    return;
  fi

  sessions=$(tmux ls)
  if [ -z "$sessions" ]; then
    return;
  fi

  selectedSession=$(echo $sessions | awk -F ':' '{print $1}' | fzf)
  if [ -z "$selectedSession" ]; then
    return;
  fi
  tmux kill-session -t $selectedSession;
}

function lvimGoToFiles {
    lvimExists=$(which nvim)
    if [ -z "$lvimExists" ]; then
      return;
    fi;

    selection=$(displayFZFFiles);
    if [ -z "$selection" ]; then
        return;
    else
        lvim $selection;
    fi;
}

function lvimGoToLine {
    lvimExists=$(which lvim)
    if [ -z "$lvimExists" ]; then
      return;
    fi
    selection=$(displayRgPipedFzf)
    if [ -z "$selection" ]; then
      return;
    else
        filename=$(echo $selection | awk -F ':' '{print $1}')
        line=$(echo $selection | awk -F ':' '{print $2}')
        lvim $(printf "+%s %s" $line $filename) +"normal zz";
    fi
}

alias vf='vimGoToFiles'
alias nf='nvimGoToFiles'
alias ngl='nvimGoToLine'
alias vgl='vimGoToLine'
alias fzd='fdFzf'
alias ta='tmuxAttachFZF'
alias tk='tmuxKillFZF'
alias lf='lvimGoToFiles'
alias lgl='lvimGoToLine'
