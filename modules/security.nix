{...}: {
  security.rtkit.enable = true;

  # PAM service used by the quickshell lock screen (LockScreen.qml)
  security.pam.services.quickshell = {};
}
