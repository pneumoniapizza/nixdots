{...}: {
  # The foot *server* is started by niri (spawn-at-startup "foot" "--server");
  # windows are opened with `footclient` (Mod+Return, fuzzel, waybar clicks).
  programs.foot = {
    enable = true;
    settings = {
      main = {
        shell = "fish";
        title = "foot";
        font = "JetBrainsMono Nerd Font:size=14";
        letter-spacing = 0;
        dpi-aware = false;
        pad = "20x20 center";
        bold-text-in-bright = false;
        gamma-correct-blending = false;
      };

      colors-dark = {
        background = "191724";
        foreground = "e0def4";
        selection-foreground = "e0def4";
        selection-background = "403d52";
        cursor = "191724 e0def4";
        urls = "c4a7e7";

        regular0 = "26233a"; # black
        regular1 = "eb6f92"; # red
        regular2 = "31748f"; # green
        regular3 = "f6c177"; # yellow
        regular4 = "9ccfd8"; # blue
        regular5 = "c4a7e7"; # magenta
        regular6 = "ebbcba"; # cyan
        regular7 = "e0def4"; # white

        bright0 = "6e6a86";
        bright1 = "eb6f92";
        bright2 = "31748f";
        bright3 = "f6c177";
        bright4 = "9ccfd8";
        bright5 = "c4a7e7";
        bright6 = "ebbcba";
        bright7 = "e0def4";
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

}
