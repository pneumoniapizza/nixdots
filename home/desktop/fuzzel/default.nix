{
  pkgs,
  ...
}: let
  # systemctl, systemd-run and niri come from the system PATH so niri msg matches the running compositor

  # Mod+BackSpace
  power-menu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [pkgs.fuzzel];
    text = ''
      choice=$(printf '%s\n' "Lock" "Suspend" "Reboot" "Shutdown" "Log out" \
        | fuzzel --dmenu --prompt "power " --width 24 --lines 5) || exit 0

      case "$choice" in
        "Lock") lock ;;
        "Suspend") systemctl suspend ;;
        "Reboot") systemctl reboot ;;
        "Shutdown") systemctl poweroff ;;
        "Log out") niri msg action quit --skip-confirmation ;;
      esac
    '';
  };

  # Mod+V
  clipboard-menu = pkgs.writeShellApplication {
    name = "clipboard-menu";
    runtimeInputs = [pkgs.fuzzel pkgs.cliphist pkgs.wl-clipboard];
    text = ''
      choice=$(cliphist list | fuzzel --dmenu --prompt "clip " --width 50 --lines 12) || exit 0
      printf '%s\n' "$choice" | cliphist decode | wl-copy
    '';
  };

  # Mod+Period (the list lives in emoji.txt: "<emoji> <search keywords>")
  emoji-menu = pkgs.writeShellApplication {
    name = "emoji-menu";
    runtimeInputs = [pkgs.fuzzel pkgs.wl-clipboard];
    text = ''
      choice=$(fuzzel --dmenu --prompt "emoji " --width 40 --lines 10 < ${./emoji.txt}) || exit 0
      printf '%s' "''${choice%% *}" | wl-copy
    '';
  };

  # Mod+T
  timer-menu = pkgs.writeShellApplication {
    name = "timer-menu";
    runtimeInputs = [pkgs.fuzzel pkgs.libnotify];
    text = ''
      choice=$(printf '%s\n' "1 min" "5 min" "10 min" "15 min" "25 min" "30 min" "1 hour" \
        | fuzzel --dmenu --prompt "timer " --width 20 --lines 7) || exit 0

      case "$choice" in
        "1 min") secs=60 ;;
        "5 min") secs=300 ;;
        "10 min") secs=600 ;;
        "15 min") secs=900 ;;
        "25 min") secs=1500 ;;
        "30 min") secs=1800 ;;
        "1 hour") secs=3600 ;;
        *) exit 0 ;;
      esac

      nsend=$(command -v notify-send)
      systemd-run --user --quiet --on-active="$secs" \
        "$nsend" -u critical -i alarm-symbolic "Timer done" "$choice elapsed"
      notify-send -t 2000 "Timer set" "$choice"
    '';
  };
in {
  home.packages = [power-menu clipboard-menu emoji-menu timer-menu];

  programs.fuzzel = {
    enable = true;
    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=13";
        # foot server + client: "Terminal=true" desktop entries open in a footclient window
        terminal = "footclient";
        icon-theme = "Papirus-Dark";
        prompt = "\"> \"";
        width = 40;
        lines = 10;
        horizontal-pad = 32;
        vertical-pad = 24;
        inner-pad = 12;
        layer = "overlay";
      };
      colors = {
        background = "191724ff";
        text = "e0def4ff";
        match = "c4a7e7ff";
        selection = "493f5bff";
        selection-text = "c4a7e7ff";
        selection-match = "c4a7e7ff";
        border = "c4a7e7ff";
      };
      border = {
        width = 2;
        radius = 12;
      };
    };
  };
}
