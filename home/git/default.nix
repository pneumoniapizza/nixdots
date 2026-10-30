{...}: {
  programs = {
    git = {
      enable = true;

      settings = {
        user = {
          name = "pneumoniapizza";
          email = "pneumoniapizza@proton.me";
        };
        url = {
          "git@git.sr.ht:".insteadOf = "sh:";
          "git@codeberg.org:".insteadOf = "cb:";
          "git@github.com:".insteadOf = "gh:";
          "git@gitlab.com:".insteadOf = "gl:";
          "git@git.sr.ht:~pneumoniapizza/".insteadOf = "me@sh:";
          "git@github.com:pneumoniapizza/".insteadOf = "me@gh:";
          "git@codeberg.org:pneumoniapizza/".insteadOf = "me@cb:";
        };
        extraConfig = {
          init.defaultBranch = "main";
          pull.rebase = false;
        };
      };
    };

    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "pneumoniapizza";
          email = "pneumoniapizza@proton.me";
        };
        ui = {
          default-command = "log";
        };
        git = {
          auto-local-bookmark = true;
        };
      };
    };
  };
}
