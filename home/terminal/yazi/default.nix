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
        chmod;        # `c m` to chmod
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
        { id = "git"; url = "*";  run = "git"; }
        { id = "git"; url = "*/"; run = "git"; }
      ];
    };

    keymap.mgr.prepend_keymap = [
      { on = "l";     run = "plugin smart-enter"; desc = "Enter dir / open file"; }
      { on = "<Enter>"; run = "plugin smart-enter"; desc = "Enter dir / open file"; }
      { on = "f";     run = "plugin jump-to-char"; desc = "Jump to char"; }
      { on = "T";     run = "plugin toggle-pane max-preview"; desc = "Maximize preview"; }
      { on = [ "c" "m" ]; run = "plugin chmod"; desc = "chmod"; }
    ];
    # NOTE: no `theme = ...` here. matugen owns theme.toml.
  };

  # Preview/search deps
  home.packages = with pkgs; [
    ffmpeg imagemagick poppler-utils resvg
    fd ripgrep fzf zoxide jq p7zip
    matugen
  ];
}
