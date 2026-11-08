{...}: {
  imports = [
    ./hardware-configuration.nix

    ../../modules/boot.nix
    ../../modules/bluetooth.nix
    ../../modules/desktop.nix
    ../../modules/gaming.nix
    ../../modules/graphics.nix
    ../../modules/locale.nix
    ../../modules/nh.nix
    ../../modules/nix-settings.nix
    ../../modules/nix-ld.nix
    ../../modules/networking.nix
    ../../modules/packages.nix
    ../../modules/security.nix
    ../../modules/services.nix
    ../../modules/users.nix
    ../../modules/virtual.nix
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
