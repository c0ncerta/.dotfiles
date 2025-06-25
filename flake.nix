{
  description = "Example nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:nix-darwin/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    # --- Home Manager como input ---
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    configuration = { pkgs, config, ... }: {
      # Paquetes instalados a nivel de sistema por nix-darwin
      environment.systemPackages =
        [ pkgs.neovim
	pkgs.tmux
	pkgs.kitty
	pkgs.kitty-themes
	pkgs.yabai
	pkgs.skhd
	pkgs.starship
	pkgs.mpv
	pkgs.yt-dlp # yt-dlp se instala aquí como un paquete del sistema
        ];

	# *** RECUERDA: LA CONFIGURACIÓN DE 'programs.yt-dlp' NO VA AQUÍ. ***
	# *** DEBE IR DENTRO DEL BLOQUE 'home-manager.users.mzzo' MÁS ABAJO. ***

	homebrew = {
	  enable = true;
	  brews = [
	    "mas"
	    "tree" # 'tree' va en brews
	    "ffmpeg"
	  ];
	  casks = [
	    "iptvnator"
	    "hammerspoon"
	  ];
	  masApps = {
	  # "appsname" = id;
	  };
	 onActivation.cleanup = "zap";
	};
	# auto upgrade
      #services.nix-daemon.enable = true ;
      environment.systemPath = [ "/opt/homebrew/bin" ];

      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 6;

      # The platform the configuration will be used on.
      nixpkgs.hostPlatform = "aarch64-darwin";
      users.users.mzzo.home = "/Users/mzzo";

      system.primaryUser = "mzzo";
    };
  in
  {
    # Construye el sistema darwin usando:
    # $ darwin-rebuild build --flake .#myzww
    darwinConfigurations."myzww" = nix-darwin.lib.darwinSystem {
      modules = [
      configuration # Carga la configuración principal de Nix-Darwin
      nix-homebrew.darwinModules.nix-homebrew
      {
          nix-homebrew = {
            enable = true;
            enableRosetta = true;
            user = "mzzo";
	    };
	}

	# --- INICIO DE LA INTEGRACIÓN DE HOME MANAGER ---
	# Este módulo carga las opciones de Home Manager en el sistema
	home-manager.darwinModules.home-manager
	{
	  # Este bloque configura Home Manager para tu usuario "mzzo"
	  home-manager.useUserPackages = true; # Permite que Home Manager gestione paquetes de usuario
	  home-manager.users.mzzo = { # Configura Home Manager para tu usuario "mzzo"
	    # IMPORTANTE: Ajusta esta versión a la versión de Home Manager que estés usando.
	    # "24.05" es la versión más reciente de la rama estable de Home Manager.
	    home.stateVersion = "24.05"; # <--- VERIFICA ESTA VERSIÓN

	    # --- AÑADIDO: Especificar explícitamente el homeDirectory ---
	    home.homeDirectory = "/Users/mzzo";

	    # LA CONFIGURACIÓN DE YT-DLP DEBE IR AQUÍ DENTRO DE ESTE BLOQUE
	    programs.yt-dlp = {
	      enable = true; # Habilita el módulo de configuración de yt-dlp
	      settings = {
		"ignore-errors" = true;
		"output" = "~/Downloads/%(title)s.%(ext)s";
		"restrict-filenames" = true;
		# Formato: HEVC (H265) hasta 1080p, luego AVC (H264) hasta 1080p, luego el mejor
		"format" = "bestvideo[vcodec^=hevc][height<=?1080]+bestaudio/bestvideo[vcodec^=avc][height<=?1080]+bestaudio/best";
		"geo-bypass" = true;
		# "geo-bypass-country" = "US"; # Descomenta y ajusta si necesitas un país específico
		"write-subs" = true;
		"all-subs" = true;
		"write-thumbnail" = true;
		"no-overwrites" = true;
		# "cookies" = "~/.config/yt-dlp/cookies.txt"; # Descomenta y ajusta si usas un archivo de cookies
	      };
	    };

	    # Puedes añadir otros programas de usuario o configuraciones de dotfiles aquí
	    # home.file.".config/my-app/config.conf".source = ./config/my-app/config.conf;
	  };
	}
	# --- FIN DE LA INTEGRACIÓN DE HOME MANAGER ---
	];
	};
	# expone el conjunto de paquetes
	
    darwinPackages = self.darwinConfigurations."myzww".pkgs;
 };
}
