{pkgs, ...}: {
  # mpv is already in home/packages.nix; yt-dlp is what mpv shells out to
  home.packages = with pkgs; [
    qutebrowser
    yt-dlp
  ];

  # config.py is static; the palette comes from matugen as
  # ~/.config/qutebrowser/colors.json and is reloaded live (:config-source)
  xdg.configFile."qutebrowser/config.py".source = ./config.py;

  # instance lists per frontend; first entry is the default.
  # your picks live in ~/.local/state/qutebrowser/frontends-choice.json
  xdg.configFile."qutebrowser/frontends.json".source = ./frontends.json;

  xdg.configFile."qutebrowser/userscripts/play" = {
    source = ./userscripts/play;
    executable = true;
  };
}
