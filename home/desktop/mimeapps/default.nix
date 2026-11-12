{lib, ...}: let
  browser = "firefox.desktop";

  assoc = app: types: lib.genAttrs types (_: app);
in {
  xdg.mimeApps = {
    enable = true;

    defaultApplications = lib.mergeAttrsList [
      (assoc browser [
        "text/html"
        "application/xhtml+xml"
        "x-scheme-handler/http"
        "x-scheme-handler/https"
        "x-scheme-handler/about"
        "x-scheme-handler/unknown"
      ])

      (assoc "org.pwmt.zathura.desktop" [
        "application/pdf"
      ])

      (assoc "swayimg.desktop" [
        "image/png"
        "image/jpeg"
        "image/gif"
        "image/webp"
        "image/avif"
        "image/bmp"
        "image/tiff"
        "image/jxl"
        "image/svg+xml"
      ])

      (assoc "mpv.desktop" [
        "video/mp4"
        "video/webm"
        "video/x-matroska"
        "video/quicktime"
        "video/x-msvideo"
        "audio/mpeg"
        "audio/flac"
        "audio/x-flac"
        "audio/ogg"
        "audio/x-wav"
      ])

      (assoc "org.qbittorrent.qBittorrent.desktop" [
        "application/x-bittorrent"
        "x-scheme-handler/magnet"
      ])
    ];
  };
}
