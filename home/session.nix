{...}: {
  home.sessionVariables = {
    # EDITOR = "emacsclient -t -a 'emacs'";
    TERMINAL = "footclient";
  };
  services.udiskie = {
    enable = true;
    tray = "auto";
  };
}
