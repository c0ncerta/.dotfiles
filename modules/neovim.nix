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
}
