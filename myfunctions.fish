#!/bin/fish
# Based on:
# https://github.com/manofthelionarmy/vimFzf-Rg/blob/master/myfunctions.sh
#
# To run this script you need to install a set of tools
# sudo apt-get install rg fzf bat git
#
# To be able to use all functions some optional tools come in handy. They take some time to setup properly. So, please google :-)
# Neovim (lua-based version of vim)
# Lunarvim (Integrated Development Environment based on Neovim)
# Tmux (Terminal Multiplexer)
#
# Default opts that set the dracula fzf color theme
#set -x FZF_DEFAULT_OPTS='--color=fg:#f8f8f2,bg:#282a36,hl:#bd93f9 --color=fg+:#f8f8f2,bg+:#44475a,hl+:#bd93f9 --color=info:#ffb86c,prompt:#50fa7b,pointer:#ff79c6 --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4 --height 80% --layout=reverse --border'
set -x FZF_DEFAULT_OPTS '--prompt="🔭 " --height 80% --layout=reverse --border'

# Default command
set -x FZF_DEFAULT_COMMAND 'rg --files --no-ignore --hidden --follow --glob "!.git/" --glob "!node_modules/" --glob "!vendor/" --glob "!undo/" --glob "!plugged/"'

# Preview them using bat
set -x BAT_THEME 'gruvbox-dark'

# TODO: make a function that does fzf at root of git project
#function gitHelper {
# # check if we are in a git project
# # https://stackoverflow.com/a/2180367
# git rev-parse --git-dir 2> /dev/null
#
# # this shows the directory for the root of the git local repo
# git rev-parse --show-toplevel | echo . | fd -t f | fzf;
#}

function displayFZFFiles
    fzf --preview 'bat --color=always --style=numbers --line-range :500 {}'
end;

function nvimGoToFiles
    set nvimExists (which nvim)
    if [ -z "$nvimExists" ];
      return;
    end

    set selection (displayFZFFiles);
    if [ -z "$selection" ];
      return;
    else
        nvim $selection;
    end
end;

function vimGoToFiles
    set vimExists (which vim)
    if [ -z "$vimExists" ];
      return;
    end

    set selection (displayFZFFiles);
    if [ -z "$selection" ];
        return;
    else
        if [ "$TERM" != "xterm-256color" ];
            set TERM "xterm-256color"
        end
        vim $selection;
    end
end;

function displayRgPipedFzf
  echo $(rg . -n --glob '!.git/' --glob '!vendor/' --glob '!node_modules/' | fzf -d ':' -n 2.. --ansi --no-sort --preview 'bat --style=numbers --color=always --highlight-line {2} {1};' --preview-window +{2}-5)
end;

function nvimGoToLine
    set nvimExists (which nvim)
    if [ -z "$nvimExists" ];
      return;
    end

    set selection (displayRgPipedFzf)
    if [ -z "$selection" ];
      return;
    else
        set filename (echo $selection | cut -d: -f1)
        set line (echo $selection | cut -d: -f2)
        nvim $filename "+$line" "+normal zz^";
    end
end;

function vimGoToLine
    set vimExists (which vim)
    if [ -z "$vimExists" ];
      return;
    end

    set selection (displayRgPipedFzf)
    if [ -z "$selection" ];
      return;
    else
        set filename (echo $selection | awk -F ':' '{print $1}')
        set line (echo $selection | awk -F ':' '{print $2}')
        if [ "$TERM" != "xterm-256color" ];
            set TERM "xterm-256color";
        end
        vim $filename "+$line" "+normal zz";
    end
  end;

function fdFzf
	set fdExists (which fd)
	if [ -z "$fdExists" ];
		return;
	else
    if [ "(pwd)" = "$HOME" ];
      set goTo (fd -t d -d 1 . | fzf --preview "bat --style=numbers --color=always --line-range :500 {}")
      if [ -z "$goTo" ];
        return;
      else
        cd $goTo
        return;
      end
    end

    set goTo (fd -t d . | grep -vE '(node_modules)' | fzf --preview "bat --style=numbers --color=always --line-range :500 {}")
    if [ -z "$goTo" ];
      return;
    else
      cd $goTo
    end
  end
end;

function tmuxAttachFZF
  set tmuxExists (which tmux)
  if [ -z "$tmuxExists" ];
    return;
  end

  set sessions (tmux ls)
  if [ -z "$sessions" ];
    return;
  end

  set selectedSession (echo $sessions | awk -F ':' '{print $1}' | fzf)
  if [ -z "$selectedSession" ];
    return;
  end
  tmux attach -t $selectedSession;
end;

function tmuxKillFZF
  set tmuxExists (which tmux)
  if [ -z "$tmuxExists" ];
    return;
  end

  set sessions (tmux ls)
  if [ -z "$sessions" ];
    return;
  end

  set selectedSession (echo $sessions | awk -F ':' '{print $1}' | fzf)
  if [ -z "$selectedSession" ];
    return;
  end
  tmux kill-session -t $selectedSession;
end;

function lvimGoToFiles
    set lvimExists (which nvim)
    if [ -z "$lvimExists" ];
      return;
    end

    set selection (displayFZFFiles);
    if [ -z "$selection" ];
        return;
    else
        lvim $selection;
    end
end;

function lvimGoToLine
    set lvimExists (which lvim)
    if [ -z "$lvimExists" ];
      return;
    end

    set selection (displayRgPipedFzf)
    if [ -z "$selection" ];
      return;
    else
        set filename (echo $selection | awk -F ':' '{print $1}')
        set line (echo $selection | awk -F ':' '{print $2}')
        lvim $filename "+$line" "+normal zz";
    end
end;

alias vf='vimGoToFiles'
alias nf='nvimGoToFiles'
alias ngl='nvimGoToLine'
alias vgl='vimGoToLine'
alias fzd='fdFzf'
alias ta='tmuxAttachFZF'
alias tk='tmuxKillFZF'
alias lf='lvimGoToFiles'
alias lgl='lvimGoToLine'
