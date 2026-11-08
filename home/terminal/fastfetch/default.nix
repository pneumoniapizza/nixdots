{...}: {
  programs.fastfetch = {
    enable = true;

    settings = {
      logo = {
        source = "nixos_small";
        padding = {
          top = 1;
          right = 3;
        };
      };

      display = {
        separator = "  ";
      };

      # keys are padded by hand so the values line up
      modules = [
        {
          type = "os";
          key = "os    ";
        }
        {
          type = "kernel";
          key = "kern  ";
          format = "{2}";
        }
        {
          type = "wm";
          key = "wm    ";
          format = "{1}";
        }
        {
          type = "shell";
          key = "shell ";
        }
        {
          type = "terminal";
          key = "term  ";
        }
        {
          type = "packages";
          key = "pkgs  ";
          format = "{nix-all}";
        }
        {
          type = "memory";
          key = "mem   ";
          format = "{1} / {2}";
        }
        {
          type = "uptime";
          key = "up    ";
        }
        "break"
        {
          type = "colors";
          symbol = "circle";
        }
      ];
    };
  };
}
