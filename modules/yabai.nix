


{
  services.yabai = {
    enable = true;
    config = {
      layout = "bsp";
      window_gap = 8;
      top_padding = 5;
      bottom_padding = 5;
      left_padding = 5;
      right_padding = 5;
    };
  };

  services.skhd = {
    enable = true;
    config = ''
      alt - h : yabai -m window --focus west
      alt - l : yabai -m window --focus east
      alt - j : yabai -m window --focus south
      alt - k : yabai -m window --focus north
    '';
  };
}

