{
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0";

  outputs =
    { self, ... }@inputs:
    let
      inherit (inputs.nixpkgs) lib;

      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forEachSystem =
        f: lib.genAttrs systems (system: f { pkgs = import inputs.nixpkgs { inherit system; }; });
    in
    {

      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              nodejs_latest
              action-validator
            ];
          };
        }
      );
    };
}
