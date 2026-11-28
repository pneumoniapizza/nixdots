{pkgs, ...}: let
  # brightnessctl + a swayosd popup (swayosd's own --brightness can pick the wrong
  # backlight on the Intel + NVIDIA laptop)
  brightness = pkgs.writeShellApplication {
    name = "brightness";
    runtimeInputs = [pkgs.brightnessctl pkgs.swayosd pkgs.gawk];
    text = ''
      brightnessctl --class=backlight set "''${1:?usage: brightness +10% | 10%-}" >/dev/null
      cur=$(brightnessctl --class=backlight get)
      max=$(brightnessctl --class=backlight max)
      swayosd-client \
        --custom-progress "$(awk -v c="$cur" -v m="$max" 'BEGIN { printf "%.2f", c / m }')" \
        --custom-progress-text "$((cur * 100 / max))%" \
        --custom-icon display-brightness-symbolic
    '';
  };
in {
  home.packages = [pkgs.swayosd brightness];
  xdg.configFile."swayosd/style.css".source = ./style.css;
}
