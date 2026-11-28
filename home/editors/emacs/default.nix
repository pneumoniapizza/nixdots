{pkgs, ...}: {
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
  };
  services.emacs = {
    enable = true;
    # defaultEditor = true;
    package = pkgs.emacs-pgtk;
  };
  home.file = {
    ".emacs.d/init.el".source = ./emacs.d/init.el;
    ".emacs.d/early-init.el".source = ./emacs.d/early-init.el;
    ".emacs.d/rose-pine-theme.el".source = ./emacs.d/rose-pine-theme.el;
  };
}
