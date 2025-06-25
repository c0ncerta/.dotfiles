


{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font";
    theme = "Dracula";
    settings = {
      enable_audio_bell = false;
    };
  };
  home.file.".config/kitty/kitty.conf".source = /Users/mzzo/.dotfiles/config/kitty/kitty.conf;
}
Last login: Wed Jun 18 18:46:07 on ttys003
mzzo@myzww:~/ > sudo darwin-rebuild switch --flake ~/.dotfiles#myzww

Password:
building the system configuration...
setting up groups...
setting up users...
setting up /Applications/Nix Apps...
setting up pam...
applying patches...
setting up /etc...
setting up launchd services...
reloading nix-daemon...
waiting for nix-daemon
configuring networking...
configuring power...
setting up /Library/Fonts/Nix Fonts...
setting nvram variables...
mzzo@myzww:~/ > which yabai                                         
/run/current-system/sw/bin/yabai
mzzo@myzww:~/ > sudo yabai --install-sa
sudo yabai --load-sa

yabai: '--install-sa' is not a valid option!
yabai: System Integrity Protection: Filesystem Protections and Debugging Restrictions must be disabled!
mzzo@myzww:~/ > sudo yabai --install-sa
sudo yabai --load-sa

yabai: '--install-sa' is not a valid option!
yabai: System Integrity Protection: Filesystem Protections and Debugging Restrictions must be disabled!
mzzo@myzww:~/ > cd ~/.dotfiles                                                                                                
mzzo@myzww:~/.dotfiles/ > nvim flake.nix 
mzzo@myzww:~/.dotfiles/ >  cd config 
mzzo@myzww:~/.dotfiles/config/ > mkdir kitty 
mzzo@myzww:~/.dotfiles/config/ > cd kitty 
mzzo@myzww:~/.dotfiles/config/kitty/ > cd ..
mzzo@myzww:~/.dotfiles/config/ > cd ..
mzzo@myzww:~/.dotfiles/ > cd modules 
mzzo@myzww:~/.dotfiles/modules/ > ls 
kitty.nix	neovim.nix	starship.nix	yabai.nix
mzzo@myzww:~/.dotfiles/modules/ > cd kitty.nix
cd: not a directory: kitty.nix
mzzo@myzww:~/.dotfiles/modules/ > nvim kitty.nix
mzzo@myzww:~/.dotfiles/modules/ > nvim kitty.nix














{ pkgs, ... }:

{
  programs.kitty = {
    enable = true;
    font.name = "JetBrainsMono Nerd Font";
    theme = "Dracula";
    settings = {
      enable_audio_bell = false;
    };
  };
  home.file.".config/kitty/kitty.conf".source = ../../config/kitty/kitty.conf;
}

~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
~
kitty.nix                                                                                                                                                  1,0-1          Tot


