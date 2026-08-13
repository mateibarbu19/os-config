{
  nixOSVersion = "26.05";

  system = "x86_64-linux";
  hostName = "nixos";

  mainUsername = "matei";
  # Used for the user config and Git also
  fullName = "Matei Barbu";
  userEmail = "mateibarbu19@disroot.org";
  fepUser = "matei.barbu1905";

  # Used for GDM and the main user
  gnomeAccentColor = "orange";

  # The one knob for colors. Everything that can be themed reads its settings
  # from the matching entry in `themes.nix`; see that file for the list.
  theme = "flexoki-light";
}
