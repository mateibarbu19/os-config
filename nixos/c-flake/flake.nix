{
  description = "Simple C/C++ dev environment";

  inputs = {
    nixpkgs.url = "nixpkgs/25.05";
  };

  outputs = {self, nixpkgs}:
  let
    pkgs = nixpkgs.legacyPackages.x86_64-linux;
  in
  {

    packages.x86_64-linux.default = pkgs.hello;

    devShells.x86_64-linux.default = pkgs.mkShell {
      buildInputs = with pkgs; [
        llvmPackages_latest.clang-tools # Order
        llvmPackages_latest.clang       # matters
        compiledb
        gnumake
      ];
    };
  };
}
