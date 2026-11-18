{pkgs, ...}: let
  # do-not-disturb toggle + JSON status for the waybar bell
  dunst-dnd = pkgs.writeShellApplication {
    name = "dunst-dnd";
    runtimeInputs = [pkgs.dunst pkgs.procps];
    text = ''
      case "''${1:-status}" in
        toggle)
          dunstctl set-paused toggle
          pkill -RTMIN+8 waybar || true
          ;;
        status)
          paused=$(dunstctl is-paused 2>/dev/null || echo false)
          if [ "$paused" = "true" ]; then
            waiting=$(dunstctl count waiting 2>/dev/null || echo 0)
            printf '{"text":"%s","alt":"paused","class":"paused","tooltip":"Do not disturb (%s waiting)"}\n' "$waiting" "$waiting"
          else
            printf '{"text":"","alt":"active","class":"active","tooltip":"Notifications on"}\n'
          fi
          ;;
        *)
          echo "usage: dunst-dnd [status|toggle]" >&2
          exit 1
          ;;
      esac
    '';
  };
in {
  # No services.dunst: matugen owns ~/.config/dunst/dunstrc, and niri starts the daemon.
  home.packages = [pkgs.dunst dunst-dnd];
}
