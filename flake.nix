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
        # nodejs and python3 come from Homebrew (higher PATH priority)
        pkgs.php
        pkgs.phpPackages.composer
        pkgs.pnpm

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
      # - GUI casks: native macOS apps
      homebrew = {
        enable = true;
        brews = [
          "mas"
          "opencode"
          # Zsh plugins now managed by home-manager (programs.zsh.*)
          # Python runtime (flake assumes python3 comes from Homebrew)
          "python@3.12"
          # RE / security tooling
          "binwalk"
          "coccinelle"
          "jadx"
          "radare2"
          "semgrep"
        ];
        casks = [
          # Core apps (managed by nix-homebrew)
          "hammerspoon"
          "cmux"
          "legcord"
          # Browsers & Editors
          "google-chrome"
          "helium-browser"
          "visual-studio-code"
          "cursor"
          "t3-code"
          # AI Assistants
          "chatgpt"
          "claude"
          # Media
          "spotify"
          # Networking
          "tailscale-app"
          "cloudflare-warp"
          # Utilities
          "orbstack"
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
        onActivation.autoUpdate = true;   # refresca taps antes de instalar/actualizar
        onActivation.upgrade = true;      # actualiza brews/casks ya instalados en cada switch
      };

      # ── System Metadata ───────────────────────────────────────
      system.configurationRevision = self.rev or self.dirtyRev or null;
      system.stateVersion = 6;
      system.primaryUser = "mzzo";

      
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
          home-manager.backupFileExtension = "backup";
          home-manager.users.mzzo = import ./home/home.nix;
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."myzww".pkgs;
  };
}
