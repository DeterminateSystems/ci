{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";

    # For action-validator, which is broken with new rust versions
    nixpkgs-old.url = "https://flakehub.com/f/NixOS/nixpkgs/0.2411.717196";
  };

  outputs =
    { nixpkgs, nixpkgs-old, ... }:
    let
      inherit (nixpkgs) lib;

      systems = [
        "aarch64-linux"
        "aarch64-darwin"
        "x86_64-linux"
      ];

      forEachSystem =
        f:
        lib.genAttrs systems (
          system:
          let
            pkgs = nixpkgs.legacyPackages.${system};
            pkgs-old = nixpkgs-old.legacyPackages.${system};
          in
          f { inherit pkgs pkgs-old; }
        );
    in
    {

      devShells = forEachSystem (
        { pkgs, pkgs-old }:
        {
          default = pkgs.mkShellNoCC {
            buildInputs = [
              pkgs.nodePackages.prettier

              pkgs-old.action-validator
            ];
          };
        }
      );
    };
}
