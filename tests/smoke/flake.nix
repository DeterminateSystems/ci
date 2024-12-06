{
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.tar.gz";
  };

  outputs = { self, nixpkgs }: {
    devShells.x86_64-linux.default = with nixpkgs.legacyPackages.x86_64-linux; mkShell {
        name = "devshell";
        buildInputs = [
            hello
        ];
    };

    packages.aarch64-darwin.default = nixpkgs.legacyPackages.aarch64-darwin.hello;
  };
}
