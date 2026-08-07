{
  inputs.nixpkgs.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/*";

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
        f:
        lib.genAttrs systems (
          system: f { pkgs = import inputs.nixpkgs { inherit system; }; }
        );
    in
    {
      devShells = forEachSystem (
        { pkgs }:
        {
          default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              action-validator
              actionlint
              prettier
              zizmor
            ];
          };
        }
      );

      formatter = forEachSystem ({ pkgs }: pkgs.nixfmt);
    };
}
