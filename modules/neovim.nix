


{ pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    vimAlias = true;
    extraConfig = ''
      set number
      syntax on
    '';
    plugins = with pkgs.vimPlugins; [
      vim-nix
      telescope-nvim
      nvim-treesitter.withAllGrammars
      nvim-lspconfig
 { config, pkgs, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;

    # Optional: specify extra packages if needed
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
   ];
  };
}
