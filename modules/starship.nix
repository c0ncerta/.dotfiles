{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;

      character = {
        success_symbol = "[➜](green)";
        error_symbol = "[➜](red)";
        vicmd_symbol = "[📝](yellow)";
      };
    };
  };
}
