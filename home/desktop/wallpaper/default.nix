{pkgs, ...}: let
  wall-backdrop = pkgs.writeShellApplication {
    name = "wall-backdrop";
    runtimeInputs = [pkgs.imagemagick]; # awww is found on PATH from your packages.nix
    text = ''
      out="''${XDG_CACHE_HOME:-$HOME/.cache}/wall-backdrop.jpg"

      # login: re-show the last blurred image (the backdrop daemon starts empty)
      if [ "''${1:-}" = "--restore" ]; then
        [ -f "$out" ] && exec awww img --namespace backdrop --transition-type none "$out"
        exit 0
      fi

      img="''${1:?usage: wall-backdrop <image> | --restore}"
      magick "$img" -resize 50% -blur 0x16 -modulate 70,110 "$out"
      exec awww img --namespace backdrop --transition-type fade "$out"
    '';
  };

  # fuzzel wallpaper picker (Mod+W): sets the wallpaper, then lets matugen
  # regenerate every theme (it also runs wall-backdrop via config.toml).
  # `wallpaper-picker --restore` re-applies the last pick at login.
  wallpaper-picker = pkgs.writeShellApplication {
    name = "wallpaper-picker";
    runtimeInputs = [pkgs.fuzzel pkgs.matugen pkgs.findutils pkgs.coreutils pkgs.gnused];
    text = ''
      dir="''${WALLPAPER_DIR:-$HOME/Pictures/wallpapers}"
      state="''${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper"

      if [ "''${1:-}" = "--restore" ]; then
        [ -f "$state" ] || exit 0
        # wait for awww-daemon to come up
        for _ in $(seq 1 40); do
          awww query >/dev/null 2>&1 && break
          sleep 0.25
        done
        exec awww img --transition-type none "$(cat "$state")"
      fi

      if [ ! -d "$dir" ]; then
        echo "wallpaper-picker: $dir does not exist" >&2
        exit 1
      fi

      choice=$(cd "$dir" && find . -type f \( -iname '*.png' -o -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.webp' -o -iname '*.gif' \) \
        | sed 's|^\./||' | sort \
        | fuzzel --dmenu --prompt "wallpaper " --width 50 --lines 12) || exit 0
      [ -n "$choice" ] || exit 0

      img="$dir/$choice"
      mkdir -p "$(dirname "$state")"
      printf '%s\n' "$img" > "$state"

      awww img --transition-type fade --transition-duration 1 "$img"
      exec matugen image "$img"
    '';
  };
in {
  home.packages = [wall-backdrop wallpaper-picker];
}
