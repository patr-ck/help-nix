{
  description = "testicles";

  inputs.haskellNix.url  = "github:input-output-hk/haskell.nix";
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-unstable";
  inputs.flake-utils.url = "github:numtide/flake-utils";
  
  outputs = { self, nixpkgs, haskellNix, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" "x86_64-darwin" ] (system:
      let
        overlays =
          [ haskellNix.overlay
            (final: prev: {
              test = final.haskell-nix.project' {
                src = ./.;
                compiler-nix-name = "ghc8104";
              };
            })
          ];
        pkgs  = import nixpkgs { inherit system overlays; };
        flake = pkgs.test.flake {};
      in
        flake // {
          defaultPackage = flake.packages."test:exe:test";

          devShell = pkgs.test.shellFor {
            tools = {
              cabal = "latest";
              haskell-language-server = "latest";
              hlint = "latest";
            };
            buildInputs = with pkgs; [];
          };
        }
    );
}
