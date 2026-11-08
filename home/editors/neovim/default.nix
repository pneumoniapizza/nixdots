{ config, pkgs, dotfiles, ... }:
{
  programs.neovim = {
    enable = true;
    sideloadInitLua = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = false;
    withPython3 = false;
    withRuby = false;

    extraPackages = with pkgs; [
      gcc
      tree-sitter
      git
      ripgrep
      fd
      lazygit

      # language servers
      clang-tools # clangd + clang-format
      zls
      rust-analyzer
      gopls
      nixd
      lua-language-server
      basedpyright
      vtsls
      vscode-langservers-extracted # html + css
      # haskell-language-server

      # formatters
      nixfmt
      stylua
      ruff
      prettier
    ];
  };

  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/editors/neovim/nvim";
}
