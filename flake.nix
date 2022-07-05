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
          test2 = final.haskell-nix.project' ( { pkgs, lib, ... }:
            let
              inherit (pkgs) stdenv;
              isCrossBuild = stdenv.hostPlatform != stdenv.buildPlatform;
            in
              {
                src = ./.;
                compiler-nix-name = "ghc8107";
                modules = [
                  # Haddock generation for webkit2gtk3 fails with:
                  # Setup: Graphics/UI/Gtk/WebKit/JavaScriptCore/JSValueRef.chi not found in:
                  # /nix/store/a2xpbp9v6qlkq9zh2bcsbfslb5nvc0rd-ghc-8.10.7/lib/ghc-8.10.7/base-4.14.3.0
                  # dist/build
                  # .
                  #
                  # See https://github.com/gtk2hs/webkit-javascriptcore/issues/6
                  { packages.webkit2gtk3-javascriptcore.doHaddock = false; }
                  # After haskell.nix revision
                  # 95faec6038f6684e4ef2a9476216bc1f72d44ffd (first bad commit), we
                  # started to see the error:
                  #
                  # Package key for wired-in dependency `ghcjs-th' could not be found:
                  # ghcjs-th-0.1.0.0-JdGbYrK1CstBZz9Zn9tGjt
                  #
                  # We need to set reinstallableLibGhc to false to workaround this
                  # (the default changed from false to true in this commit):
                  (lib.mkIf isCrossBuild { reinstallableLibGhc = false; })
                ];

                shell = {
                  name = "dev-shell";
                  packages = ps: [ ps.test2 ];

                  crossPlatforms = p: [ p.ghcjs ];

                  meta.platforms = lib.platforms.unix;
                };
              }
          );
	      }) ];
        pkgs = import nixpkgs { inherit system overlays; };
        flake = pkgs.test2.flake {
              crossPlatforms = p: with p; [ ghcjs ];
        };
      in
        flake // {
          defaultPackage = flake.packages."test2:exe:test2";
        }
    ));
}
