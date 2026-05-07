{
  description = "Nix-darwin system flake for mzzo";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # Home Manager
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    configuration = { pkgs, config, ... }: {
      # ── System Packages ──────────────────────────────────────
      environment.systemPackages = [
        # Editors & Tools
        pkgs.neovim
        pkgs.tmux

        # Window Manager
        # pkgs.yabai  # disabled - backup only
        pkgs.skhd

        # Media
        pkgs.mpv
        pkgs.ffmpeg
        pkgs.whisper-cpp
        pkgs.tesseract

        # CLI Tools
        pkgs.fzf
        pkgs.ripgrep
        pkgs.tree
        pkgs.cloc
        pkgs.atuin
        pkgs.curl
        pkgs.git
        pkgs.starship
        pkgs.eza
        pkgs.zoxide
        pkgs.mitmproxy
        pkgs.bun

        # Languages & Runtimes
        pkgs.python312
        pkgs.php
        pkgs.phpPackages.composer
        pkgs.pyenv
        pkgs.pipx
        pkgs.nodejs
        pkgs.bun

        # Media Tools
        pkgs.yt-dlp
        pkgs.ryubing
      ];

      # ── System PATH — prepend Homebrew to nix-darwin defaults ──
      # nix-darwin default PATH includes:
      # ~/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:
      # /run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:
      # /usr/local/bin:/usr/bin:/usr/sbin:/bin:/sbin
      # We prepend Homebrew so it takes priority.
      environment.extraInit = ''
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
      '';

      # ── Nix Settings ─────────────────────────────────────────
      nix.settings.experimental-features = "nix-command flakes";
      nix.settings.auto-optimise-store = true;

      # ── Homebrew Integration ──────────────────────────────────
      # Things not in nixpkgs or macOS-specific:
      # - mas: Mac App Store CLI
      # - opencode: not in nixpkgs
      # - zinit + zsh plugins: loaded via ~/.zshrc from Homebrew paths
      # - GUI casks: native macOS apps
      homebrew = {
        enable = true;
        brews = [
          "mas"
          "opencode"
          "zinit"
          # Zsh plugins — loaded via zinit from Homebrew paths in ~/.zshrc
          "zsh-syntax-highlighting"
          "zsh-autosuggestions"
          "zsh-history-substring-search"
        ];
        casks = [
          # Core apps (managed by nix-homebrew)
          "iptvnator"
          "hammerspoon"
          "cmux"
          "legcord"
          # Browsers & Editors
          "google-chrome"
          "helium-browser"
          "visual-studio-code"
          "cursor"
          # AI Assistants
          "chatgpt"
          "claude"
          # Media
          "spotify"
          # Networking
          "tailscale-app"
          "cloudflare-warp"
          # Utilities
          "qbittorrent"
          "anydesk"
          "manus"
          "macwhisper"
          "shutter-encoder"
        ];
        masApps = {
          "GarageBand" = 682658836;
          "HP Smart" = 1474276998;
          "Keynote" = 409183694;
          "Pages" = 409201541;
          "uBlock Origin Lite" = 6745342698;
          "Unzip - RAR ZIP 7Z Unarchiver" = 1537056818;
          "WhatsApp" = 310633997;
          "WireGuard" = 1451685025;
        };
        onActivation.cleanup = "zap";
      };

      # ── System Metadata ───────────────────────────────────────
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      system.primaryUser = "mzzo";

      # ── Yabai & skhd (window manager + hotkeys) ──
      # yabai disabled - backup only
      # services.yabai = {
      #   enable = true;
      #   config = {
      #     layout = "bsp";
      #     window_gap = 8;
      #     top_padding = 5;
      #     bottom_padding = 5;
      #     left_padding = 5;
      #     right_padding = 5;
      #   };
      # };
      services.skhd = {
        enable = true;
        skhdConfig = ''
          alt - h : yabai -m window --focus west
          alt - l : yabai -m window --focus east
          alt - j : yabai -m window --focus south
          alt - k : yabai -m window --focus north
        '';
      };

      # ── Platform ──────────────────────────────────────────────
      nixpkgs.hostPlatform = "aarch64-darwin";
    };
  in
  {
    darwinConfigurations."myzww" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "mzzo";
          };
        }

        # Home Manager integration — imports home/home.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.mzzo = import ./home/home.nix;
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."myzww".pkgs;
  };
}
