{...}: {
  nix.settings = {
    experimental-features = ["nix-command" "flakes"];
    warn-dirty = false;
  };

  # hard-link identical store files, weekly
  nix.optimise.automatic = true;

  # nix-gaming ships a binary cache so osu-lazer etc. aren't built locally.
  # Copy the substituter URL + public key from the nix-gaming README into:
  #   nix.settings.substituters = [ ... ];
  #   nix.settings.trusted-public-keys = [ ... ];
}
