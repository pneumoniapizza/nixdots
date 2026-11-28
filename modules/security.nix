{...}: {
  security.rtkit.enable = true;

  # PAM service used by swaylock (home/desktop/lock)
  security.pam.services.swaylock = {};
}
