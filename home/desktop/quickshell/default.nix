{ config, pkgs, ... }:

let
  shellDir = "${config.home.homeDirectory}/dotfiles/home/desktop/quickshell/bar";
in
{
  xdg.configFile."quickshell".source =
    config.lib.file.mkOutOfStoreSymlink shellDir;
}
