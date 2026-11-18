{
  description = "my dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # these two used to bring their own nixpkgs; following keeps one copy to eval/download
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    vivy = {
      url = "github:pneumoniapizza/vivy";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    ...
  }: let
    system = "x86_64-linux";

    # single place for the checkout path (used by nh, neovim and hypr live-edit symlinks)
    dotfiles = "/home/daksh/dotfiles";

    pkgs = import nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
  in {
    # `nix fmt` formats the whole repo
    formatter.${system} = pkgs.alejandra;

    devShells.${system}.default = pkgs.mkShell {
      packages = with pkgs; [
        nixd
        alejandra
        statix
        deadnix
      ];
    };

    nixosConfigurations.zeus = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = {inherit inputs dotfiles;};
      modules = [
        ./hosts/zeus
      ];
    };

    homeConfigurations.daksh = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      extraSpecialArgs = {inherit inputs dotfiles;};
      modules = [
        ./home
      ];
    };
  };
}
