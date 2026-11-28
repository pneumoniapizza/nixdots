{...}: {
  programs.zathura = {
    enable = true;

    options = {
      font = "MonaspiceNe Nerd Font 10";
      guioptions = "s"; # statusbar only, no scrollbars or inputbar clutter
      selection-clipboard = "clipboard";
      adjust-open = "best-fit";
      pages-per-row = 1;
      scroll-page-aware = true;
      statusbar-home-tilde = true;
      window-title-home-tilde = true;

      # recolor pages in rose-pine (toggle with Ctrl+R)
      recolor = true;
      recolor-keephue = true;
      highlight-transparency = 0.4;
    };

    extraConfig = ''
      set default-bg                  "#191724"
      set default-fg                  "#e0def4"

      set statusbar-bg                "#1f1d2e"
      set statusbar-fg                "#e0def4"

      set inputbar-bg                 "#1f1d2e"
      set inputbar-fg                 "#e0def4"

      set notification-bg             "#26233a"
      set notification-fg             "#e0def4"
      set notification-error-bg       "#543043"
      set notification-error-fg       "#eb6f92"
      set notification-warning-bg     "#54454e"
      set notification-warning-fg     "#ebbcba"

      set completion-bg               "#1f1d2e"
      set completion-fg               "#908caa"
      set completion-group-bg         "#26233a"
      set completion-group-fg         "#c4a7e7"
      set completion-highlight-bg     "#c4a7e7"
      set completion-highlight-fg     "#191724"

      set index-bg                    "#191724"
      set index-fg                    "#e0def4"
      set index-active-bg             "#c4a7e7"
      set index-active-fg             "#191724"

      set highlight-color             "#c4a7e7"
      set highlight-fg                "#ebbcba"
      set highlight-active-color      "#ebbcba"

      set recolor-lightcolor          "#191724"
      set recolor-darkcolor           "#e0def4"
    '';
  };
}
