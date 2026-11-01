{pkgs, lib, ...}: {
  # Use the systemd-boot EFI boot loader.
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
