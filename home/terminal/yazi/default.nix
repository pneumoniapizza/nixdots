{ pkgs, ... }:
{
  programs.yazi = {
    enable = true;
    enableFishIntegration = true; # or Zsh / Fish / Nushell / Bash
    shellWrapperName = "y";       # `y` cd's into the dir you quit in

    # Plugins straight from nixpkgs, no manual `ya pkg` needed
    plugins = {
      inherit (pkgs.yaziPlugins)
        full-border   # clean rounded border
        smart-enter   # enter dirs / open files with one key
        git           # git status marks in the file list
        jump-to-char  # f + char to jump
        toggle-pane   # maximize the preview with T
        chmod         # `c m` to chmod
        sudo;
    };

    initLua = ''
      require("full-border"):setup()
      require("git"):setup()
    '';

    settings = {
      mgr = {
        ratio = [ 1 4 3 ];
        sort_by = "natural";
        sort_dir_first = true;
        show_hidden = false;
        show_symlink = true;
        linemode = "size";
      };
      preview = {
        max_width = 1000;
        max_height = 1000;
      };
      plugin.prepend_fetchers = [
        { group = "git"; url = "*";  run = "git"; }
        { group = "git"; url = "*/"; run = "git"; }
      ];
    };

    keymap.mgr.prepend_keymap = [
      { on = "l";     run = "plugin smart-enter"; desc = "Enter dir / open file"; }
      { on = "<Enter>"; run = "plugin smart-enter"; desc = "Enter dir / open file"; }
      { on = "f";     run = "plugin jump-to-char"; desc = "Jump to char"; }
      { on = "T";     run = "plugin toggle-pane max-preview"; desc = "Maximize preview"; }
      { on = [ "c" "m" ]; run = "plugin chmod"; desc = "chmod"; }

      # sudo mode, all under the "R" prefix
      { on = [ "R" "p" "p" ]; run = "plugin sudo -- paste";                desc = "sudo paste"; }
      { on = [ "R" "P" ];     run = "plugin sudo -- paste --force";        desc = "sudo paste (overwrite)"; }
      { on = [ "R" "r" ];     run = "plugin sudo -- rename";               desc = "sudo rename"; }
      { on = [ "R" "p" "l" ]; run = "plugin sudo -- link";                 desc = "sudo symlink"; }
      { on = [ "R" "p" "r" ]; run = "plugin sudo -- link --relative";      desc = "sudo relative symlink"; }
      { on = [ "R" "p" "L" ]; run = "plugin sudo -- hardlink";             desc = "sudo hardlink"; }
      { on = [ "R" "a" ];     run = "plugin sudo -- create";               desc = "sudo create"; }
      { on = [ "R" "d" ];     run = "plugin sudo -- remove";               desc = "sudo trash"; }
      { on = [ "R" "D" ];     run = "plugin sudo -- remove --permanently"; desc = "sudo delete permanently"; }
    ];
  };

  # Preview/search deps
  home.packages = with pkgs; [
    ffmpeg imagemagick poppler-utils resvg
    fd ripgrep fzf zoxide jq p7zip
  ];
}
