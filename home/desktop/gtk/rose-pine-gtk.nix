{pkgs}: let
  inherit (pkgs) stdenvNoCC fetchFromGitHub;

  rose-pine-gtk = stdenvNoCC.mkDerivation rec {
    pname = "rose-pine-gtk-theme";
    version = "2.2.0";

    src = fetchFromGitHub {
      owner = "rose-pine";
      repo = "gtk";
      tag = "v${version}";
      hash = "sha256-vCWs+TOVURl18EdbJr5QAHfB+JX9lYJ3TPO6IklKeFE=";
    };

    # avoid the makefile which is only for theme maintainers
    dontBuild = true;

    installPhase = ''
      runHook preInstall

      mkdir -p $out/share/themes/rose-pine/gtk-4.0
      cp -r $src/gtk3/rose-pine-gtk/* $out/share/themes/rose-pine
      cp -r $src/gtk4/rose-pine.css $out/share/themes/rose-pine/gtk-4.0/gtk.css

      runHook postInstall
    '';
  };
in
  rose-pine-gtk
