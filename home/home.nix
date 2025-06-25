


{ config, pkgs, ... }:

{
  imports = [
    ../modules/neovim.nix
    ../modules/kitty.nix
    ../modules/starship.nix
    ../modules/yabai.nix
  ];

  home.username = "mzzo";
  home.homeDirectory = "/Users/mzzo";
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;

  home.packages = with pkgs; [
    git
    bat
    ripgrep
    fd
    zoxide
  ];
}

