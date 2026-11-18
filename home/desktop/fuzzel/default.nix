{
  config,
  pkgs,
  ...
}: let
  # fuzzel-driven power menu (Mod+Backspace and the bar's power button)
  power-menu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [pkgs.fuzzel]; # systemctl and niri come from the system PATH so niri msg matches the running compositor
    text = ''
      choice=$(printf '%s\n' "Suspend" "Reboot" "Shutdown" "Log out" \
        | fuzzel --dmenu --prompt "power " --width 24 --lines 4) || exit 0

      case "$choice" in
        "Suspend") systemctl suspend ;;
        "Reboot") systemctl reboot ;;
        "Shutdown") systemctl poweroff ;;
        "Log out") niri msg action quit --skip-confirmation ;;
      esac
    '';
  };
in {
  home.packages = [power-menu];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "MonaspiceNe Nerd Font:size=13";
        # foot server + client: "Terminal=true" desktop entries open in a footclient window
        terminal = "footclient";
        icon-theme = "Papirus-Dark";
        prompt = "\"> \"";
        width = 36;
        lines = 10;
        horizontal-pad = 24;
        vertical-pad = 16;
        inner-pad = 8;
        layer = "overlay";
        # colors, written by matugen
        include = "${config.home.homeDirectory}/.config/fuzzel/theme.ini";
      };
      border = {
        width = 2;
        radius = 0;
      };
    };
  };
}
