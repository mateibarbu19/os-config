{
  nixOSVersion = "25.05";

  system = "x86_64-linux";
  hostName = "nixos";
  
  mainUsername = "matei";
  # Used for the user config and Git also
  fullName = "Matei Barbu";
  userEmail = "mateibarbu19@disroot.org";

  # Used for GDM and the main user
  gnomeAccentColor = "orange";
}
