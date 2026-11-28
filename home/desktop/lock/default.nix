{pkgs, ...}: let
  # blurred wallpaper (from wall-backdrop) as the lock background when there is one
  lock = pkgs.writeShellApplication {
    name = "lock";
    runtimeInputs = [pkgs.swaylock];
    text = ''
      img="''${XDG_CACHE_HOME:-$HOME/.cache}/wall-backdrop.jpg"
      if [ -f "$img" ]; then
        exec swaylock -f -i "$img" -s fill
      fi
      exec swaylock -f
    '';
  };
in {
  home.packages = [lock];
  xdg.configFile."swaylock/config".source = ./swaylock-config;
}
