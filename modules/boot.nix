{
  pkgs,
  lib,
  ...
}: {
  # Limine as the EFI bootloader.
  boot.loader.limine.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.supportedFilesystems = {
    btrfs = true;
    zfs = lib.mkForce false;
    ntfs = true;
  };
}
