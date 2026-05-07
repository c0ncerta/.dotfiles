{ config, lib, pkgs, ... }:

{
  home.homeDirectory = lib.mkForce "/Users/mzzo";
  home.stateVersion = "24.05";

  imports = [
    ./../modules/neovim.nix
    ./../modules/starship.nix
  ];

  programs.home-manager.enable = true;

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

  # ── Ghostty Config ──────────────────────────────────
  home.file.".config/ghostty/config".source = ../config/ghostty/config;

  # ── Helium Browser Extensions ───────────────────────
  home.activation.installHeliumExtensions = lib.hm.dag.entryAfter ["writeBoundary"] ''
    EXT_IDS="bcocdbombenodlegijagbhdjbifpiijp bkdgflcldnnnapblkhphbgpggdiikppg fcjmgeodgobggcppooncdagfkogfffdm fodjlahkdpmcpdppcgmmbnifokncelcn hifcahjlgbmhppcoppikpcceognjcjjp hlklimbmgnihhjgfnlpmapicjknfidob jdopjjmdionbeefiinjkmeadngonikoh mafcolokinicfdmlidhaebadidhdehpk nngceckbapebfimnlniiiahkandclblb pkehgijcmpdhfbdbbnkijodmdjhbjlgp"
    HELIUM_EXT="$HOME/Library/Application Support/net.imput.helium/Default/Extensions"
    mkdir -p "$HELIUM_EXT"

    for EXT_ID in $EXT_IDS; do
      if ls "$HELIUM_EXT/$EXT_ID"/*/manifest.json &>/dev/null; then
        continue
      fi
      echo "[$0] Downloading extension: $EXT_ID"
      /usr/bin/python3 -c "
import urllib.request, zipfile, tempfile, os, struct, json

ext_id = '$EXT_ID'
heliu_ext = os.path.expanduser('$HELIUM_EXT')
url = f'https://clients2.google.com/service/update2/crx?response=redirect&prodversion=130.0.0.0&acceptformat=crx2,crx3&x=id%3D{ext_id}%26uc'

req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
with urllib.request.urlopen(req, timeout=30) as resp:
    data = resp.read()

offset = 0
if data[:4] == b'Cr24':
    if data[4:8] == b'\x03\x00\x00\x00':
        offset = 12 + struct.unpack('<I', data[8:12])[0]
    elif data[4:8] == b'\x02\x00\x00\x00':
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

  # ── Gemini CLI ────────────────────────────────────
  # Installed via pipx for reproducibility
  home.activation.installGeminiCLI = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -x "$HOME/.local/bin/gemini-cli" ]; then
      echo "[$0] Installing Gemini CLI via pipx..."
      ${pkgs.pipx}/bin/pipx install gemini-cli
      echo "[$0] Gemini CLI installed."
    else
      echo "[$0] Gemini CLI already installed."
    fi
  '';

  # ── Additional packages ─────────────────────────────
  home.packages = with pkgs; [
    bat
    fd
    jq
  ];
}
