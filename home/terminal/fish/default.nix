{pkgs, ...}: {
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      # remove the startup message
      set -g fish_greeting

      # transient prompt: collapse old prompts to just the character
      function starship_transient_prompt_func
          starship module character
      end
    '';

    functions = {
      fish_user_key_bindings = {
        body = ''
          fish_vi_key_bindings default 2>/dev/null

          # cursor shape per vi mode
          set -g fish_cursor_default block
          set -g fish_cursor_insert line blink
          set -g fish_cursor_replace_one underscore
          set -g fish_cursor_visual block

          # accept autosuggestion with ctrl-f in insert mode
          bind -M insert ctrl-f accept-autosuggestion
        '';
      };

      # fuzzy-pick processes and kill them (tab = multi-select, optional signal arg, default 15)
      fkill = {
        description = "Fuzzy-pick processes to kill";
        body = ''
          set -l sig 15
          if set -q argv[1]
              set sig $argv[1]
          end
          set -l pids (ps -eo pid,user,comm,args --sort=-%cpu | sed 1d | fzf -m --prompt "kill> " --header "tab: multi-select, enter: kill -$sig" | awk '{print $1}')
          if test -n "$pids"
              kill -$sig $pids
          end
        '';
      };

      # fuzzy-find a file under the current dir (or given dirs) and open it in $EDITOR
      ff = {
        description = "Fuzzy-find a file and open it in $EDITOR";
        body = ''
          set -l file (rg --files --hidden --glob '!.git' $argv | fzf --prompt "file> ")
          if test -n "$file"
              $EDITOR $file
          end
        '';
      };

      # live ripgrep search through fzf; enter opens the match in $EDITOR at that line
      rgf = {
        description = "Live ripgrep search with fzf, opens match in $EDITOR";
        body = ''
          set -l rg_prefix "rg --column --line-number --no-heading --color=always --smart-case"
          set -l selection (
              fzf --ansi --disabled --query "$argv" \
                  --bind "start:reload:$rg_prefix {q}" \
                  --bind "change:reload:sleep 0.1; $rg_prefix {q} || true" \
                  --delimiter : \
                  --prompt "rg> "
          )
          if test -n "$selection"
              set -l parts (string split -m 3 : -- $selection)
              $EDITOR +$parts[2] $parts[1]
          end
        '';
      };
    };

    shellAliases = {
      ls = "eza --icons";
      # ls = "eza --icons --group-directories-first -1";
    };

    shellAbbrs = {
      cd = "z";
      nr = "nix run";
      vim = "nvim";

      # ls
      l = "ls -l";
      ll = "ls -l";
      la = "ls -a";
      lla = "ls -la --header";
      lt = "ls --tree";

      # bash-style !!
      "!!" = {
        position = "anywhere";
        function = "last_history_item";
      };
    };

    plugins = [
      {
        name = "autopair";
        src = pkgs.fishPlugins.autopair.src;
      }
      {
        name = "done";
        src = pkgs.fishPlugins.done.src;
      }
      {
        name = "sponge";
        src = pkgs.fishPlugins.sponge.src;
      }
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
  };

  # Fuzzy finder: ctrl-t files, alt-c dirs (ctrl-r is left to atuin).
  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    historyWidget.command = "";
    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
    ];
  };

  # Takes over ctrl-r from fzf.
  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = ["--disable-up-arrow"];
  };
}
