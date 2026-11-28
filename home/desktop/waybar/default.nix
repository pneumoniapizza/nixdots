{
  config,
  pkgs,
  ...
}: let
  waybarDir = "${config.home.homeDirectory}/dotfiles/home/desktop/waybar";

  # bell / do-not-disturb state of dunst for the bar (left click: last notification,
  # right click: toggle do-not-disturb)
  notif-status = pkgs.writeShellApplication {
    name = "notif-status";
    runtimeInputs = [pkgs.dunst];
    text = ''
      paused=$(dunstctl is-paused 2>/dev/null || echo false)
      count=$(dunstctl count history 2>/dev/null || echo 0)
      if [ "$paused" = "true" ]; then
        printf '{"alt":"dnd","tooltip":"Do not disturb"}\n'
      else
        printf '{"alt":"on","tooltip":"%s in history"}\n' "$count"
      fi
    '';
  };
in {
  home.packages = [notif-status];

  # live-edit symlinks
  xdg.configFile = {
    "waybar/config.jsonc".source = config.lib.file.mkOutOfStoreSymlink "${waybarDir}/config.jsonc";
    "waybar/style.css".source = config.lib.file.mkOutOfStoreSymlink "${waybarDir}/style.css";
    "waybar/colors.css".source = config.lib.file.mkOutOfStoreSymlink "${waybarDir}/colors.css";
  };
}
