{ pkgs, config, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;

    extraPackages = with pkgs; [
      nodejs
      ripgrep
      fd
      git
    ];
  };

  # Symlink custom config
  home.file.".config/nvim/init.lua".source = ../../config/nvim/init.lua;
  home.file.".config/nvim/lua".source = ../../config/nvim/lua;
}
