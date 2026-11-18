{config, ...}: {
  # The foot *server* is started by niri (spawn-at-startup "foot" "--server");
  # windows are opened with `footclient` (Mod+Return, fuzzel, waybar clicks).
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "fish";
        title = "foot";
        font = "MonaspiceNe Nerd Font:size=14";
        letter-spacing = 0;
        dpi-aware = false;
        pad = "20x20 center";
        bold-text-in-bright = false;
        gamma-correct-blending = false;
        # colors, written by matugen (read once when the server starts)
        include = "${config.home.homeDirectory}/.config/foot/theme.ini";
      };

      scrollback.lines = 10000;

      key-bindings = {
        scrollback-up-page = "Page_Up";
        scrollback-down-page = "Page_Down";
        search-start = "Control+Shift+f";
      };

      search-bindings = {
        cancel = "Escape";
        find-prev = "Shift+F3";
        find-next = "F3 Control+G";
      };
    };
  };

  # foot --server never re-reads its config, so windows opened after a matugen
  # run would keep the old palette. matugen also writes ~/.config/foot/sequences
  # (OSC color codes) and pushes it to running terminals; new shells apply it here.
  programs.fish.interactiveShellInit = ''
    if string match -q 'foot*' -- $TERM; and test -r ~/.config/foot/sequences
        cat ~/.config/foot/sequences
    end
  '';
}
