{
  description = "testicles";

  inputs.haskellNix = {
    url = "github:input-output-hk/haskell.nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.nixpkgs.follows = "haskellNix/nixpkgs-2105";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, haskellNix, flake-utils }:
    builtins.trace haskellNix (flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        overlays = [ haskellNix.overlay (final: prev: {
        test2 = final.haskell-nix.project' {
          src = ./.;
          compiler-nix-name = "ghc8107";
          modules = [
            { packages.webkit2gtk3-javascriptcore.doHaddock = false; }
          ];
        };
	      }) ];
        pkgs = import nixpkgs { inherit system overlays; };
        flake = pkgs.test2.flake {};
      in
        flake // {
          defaultPackage = flake.packages."test2:exe:test2";
        }
    ));
}
