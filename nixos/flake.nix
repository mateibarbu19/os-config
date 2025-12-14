# There variable handling is not ideal...
# https://github.com/NixOS/nix/issues/3966
# https://discourse.nixos.org/t/cant-use-let-for-inputs/66778

{
  description = "Matei's NixOS Config";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flatpaks.url = "github:in-a-dil-emma/declarative-flatpak/v4.1.1";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    rosePineFlavors = {
      url = "github:rose-pine/yazi";
      flake = false;
    };
    rosePineTextMateTheme = {
      url = "github:rose-pine/tm-theme";
      flake = false;
    };
    deltaThemes = {
      url = "https://raw.githubusercontent.com/dandavison/delta/0.18.2/themes.gitconfig";
      flake = false;
    };
  };

  outputs =
    { nixpkgs, ... }@args:
    let
      vars = import ./variables.nix;
    in
    {
      nixosConfigurations.${vars.hostName} = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit vars;
          parentArgs = args;
          source = args.self;
        };

        modules = [
          ./nix-settings.nix
          ./configuration.nix
          args.home-manager.nixosModules.default
          args.flatpaks.nixosModules.default
        ];
      };
    };
}
