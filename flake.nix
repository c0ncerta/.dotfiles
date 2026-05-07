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
        pkgs.kitty
        pkgs.kitty-themes

        # Window Manager
        pkgs.yabai
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

        # Languages & Version Managers
        pkgs.python312
        pkgs.php
        pkgs.phpPackages.composer
        pkgs.pyenv
        pkgs.pipx
        pkgs.nodejs

        # Node.js alternatives: pkgs.nodejs_18, nodejs_20, nodejs_22
        # nvm is not in nixpkgs — use Nix to switch Node versions instead:
        #   nix shell nixpkgs#nodejs_20

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

        # Home Manager integration
        home-manager.darwinModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.users.mzzo = { config, lib, pkgs, ... }: {
            home.homeDirectory = lib.mkForce "/Users/mzzo";
            home.stateVersion = "24.05";

            # ── Git Config ──────────────────────────────────────
            programs.git = {
              enable = true;
              settings = {
                user.name = "Mzzo User";
                user.email = "c0ncerta@proton.me";
                url."git@github.com:".insteadOf = "https://github.com/";
                init.defaultBranch = "main";
                core.editor = "nvim";
                color.ui = "auto";
              };
            };

            # ── ZSH ─────────────────────────────────────────────
            programs.zsh = {
              enable = true;
              history = {
                size = 50000;
                save = 50000;
                share = true;
                expireDuplicatesFirst = true;
                ignoreSpace = true;
                ignoreAllDups = true;
                extended = true;
                append = true;
              };
              shellAliases = {
                # Modern replacements
                ls = "eza --icons --group-directories-first";
                ll = "eza -la --icons --group-directories-first";
                la = "eza -A --icons --group-directories-first";
                l = "eza --icons --group-directories-first";
                # Navigation
                ".." = "cd ..";
                "..." = "cd ../..";
                # Utilities
                grep = "grep --color=auto";
                # PAI-OpenCode
                pai = "bun ~/git-repo/pai-opencode/PAI-Install/cli/quick-install.ts";
              };
              initContent = ''
                # PATH deduplication (before anything else)
                typeset -U PATH

                # ── Zinit Plugin Manager ────────────────────────────
                if [[ -f /opt/homebrew/opt/zinit/zinit.zsh ]]; then
                  source /opt/homebrew/opt/zinit/zinit.zsh

                  # Syntax highlighting (load first for correct highlighting)
                  zinit light zsh-users/zsh-syntax-highlighting

                  # Autosuggestions
                  zinit light zsh-users/zsh-autosuggestions
                  ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=8'
                  ZSH_AUTOSUGGEST_USE_ASYNC=true

                  # History substring search
                  zinit light zsh-users/zsh-history-substring-search
                  bindkey '^[[A' history-substring-search-up
                  bindkey '^[[B' history-substring-search-down
                  [[ -n "''${key[UP]}" ]]   && bindkey "''${key[UP]}"   history-substring-search-up
                  [[ -n "''${key[DOWN]}" ]] && bindkey "''${key[DOWN]}" history-substring-search-down
                  ZSH_HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_FOUND='bg=green,fg=black,bold'
                  ZSH_HISTORY_SUBSTRING_SEARCH_HIGHLIGHT_NOT_FOUND='bg=red,fg=white,bold'
                  ZSH_HISTORY_SUBSTRING_SEARCH_GLOBBING_FLAGS='i'
                fi
              '';
              setOptions = [
                "AUTO_CD"
                "AUTO_PUSHD"
                "PUSHD_IGNORE_DUPS"
                "NO_BEEP"
                "AUTO_LIST"
                "AUTO_MENU"
                "ALWAYS_TO_END"
              ];
            };

            # ── Starship Prompt ─────────────────────────────────
            programs.starship = {
              enable = true;
            };

            # ── yt-dlp Config ───────────────────────────────────
            programs.yt-dlp = {
              enable = true;
              settings = {
                "ignore-errors" = true;
                "output" = "~/Downloads/%(title)s.%(ext)s";
                "restrict-filenames" = true;
                "format" = "bestvideo[vcodec^=hevc][height<=?1080]+bestaudio/bestvideo[vcodec^=avc][height<=?1080]+bestaudio/best";
                "geo-bypass" = true;
                "write-subs" = true;
                "all-subs" = true;
                "write-thumbnail" = true;
                "no-overwrites" = true;
              };
            };

            # ── Ghostty / cmux Config ───────────────────────────
            home.file.".config/ghostty/config".text = ''
              # cmux configuration (Ghostty-based terminal)
              # https://ghostty.org/docs/config/reference

              theme = "Catppuccin Mocha"
              font-family = "JetBrainsMono Nerd Font"
              font-size = 14
            '';

            # ── Helium Browser Extensions ───────────────────────
            # Chromium-based: downloads extensions from Chrome Web Store
            # The Python CRX downloader handles CRX2/CRX3 headers correctly
            home.activation.installHeliumExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
              EXT_IDS="bcocdbombenodlegijagbhdjbifpiijp bkdgflcldnnnapblkhphbgpggdiikppg fcjmgeodgobggcppooncdagfkogfffdm fodjlahkdpmcpdppcgmmbnifokncelcn hifcahjlgbmhppcoppikpcceognjcjjp hlklimbmgnihhjgfnlpmapicjknfidob jdopjjmdionbeefiinjkmeadngonikoh mafcolokinicfdmlidhaebadidhdehpk nngceckbapebfimnlniiiahkandclblb pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
              HELIUM_EXT="$HOME/Library/Application Support/net.imput.helium/Default/Extensions"
              mkdir -p "$HELIUM_EXT"

              for EXT_ID in $EXT_IDS; do
                # Skip if any version already exists
                if ls "$HELIUM_EXT/$EXT_ID"/*/manifest.json &>/dev/null; then
                  continue
                fi
                echo "[$0] Downloading extension: $EXT_ID"
                /usr/bin/python3 -c "
              import urllib.request, zipfile, tempfile, os, struct, json, glob

              ext_id = '$EXT_ID'
              heliu_ext = os.path.expanduser('$HELIUM_EXT')
              url = f'https://clients2.google.com/service/update2/crx?response=redirect&prodversion=130.0.0.0&acceptformat=crx2,crx3&x=id%3D{ext_id}%26uc'

              req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
              with urllib.request.urlopen(req, timeout=30) as resp:
                  data = resp.read()

              # Handle CRX3 header
              offset = 0
              if data[:4] == b'Cr24':
                  if data[4:8] == b'\x03\x00\x00\x00':  # CRX3
                      offset = 12 + struct.unpack('<I', data[8:12])[0]
                  elif data[4:8] == b'\x02\x00\x00\x00':  # CRX2
                      offset = 16 + struct.unpack('<I', data[12:16])[0]

              with tempfile.NamedTemporaryFile(suffix='.zip', delete=False) as tf:
                  tf.write(data[offset:])
                  tf.flush()
                  with zipfile.ZipFile(tf.name) as zf:
                      manifest = json.loads(zf.read('manifest.json'))
                      ver = manifest['version']
                      dest = os.path.join(heliu_ext, ext_id, f'{ver}_0')
                      os.makedirs(dest, exist_ok=True)
                      zf.extractall(dest)
              print(f'  Installed {ext_id} v{ver}')
              " 2>&1 || echo "[$0] Failed: $EXT_ID"
              done
            '';
          };
        }
      ];
    };

    darwinPackages = self.darwinConfigurations."myzww".pkgs;
  };
}
