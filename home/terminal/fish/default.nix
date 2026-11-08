{ pkgs, ... }:
{
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

    # ── vi mode ───────────────────────────────────────────────
    functions = {
      fish_user_key_bindings = {
        body = ''
          fish_vi_key_bindings default 2>/dev/null
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
      yy = "yazi";
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
      # removes mistyped cmds from history
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
    ];
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
    enableTransience = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
    historyWidget.command = "";
  };

  programs.atuin = {
    enable = true;
    enableFishIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };
}
