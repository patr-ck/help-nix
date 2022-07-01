# Help-Nix

## Build Project With Cabal in Nix Environment

```
nix develop
```

### GHC-JS

```
js-unknown-ghcjs-cabal build
# Open ./dist-newstyle/build/js-ghcjs/ghcjs-8.10.7/test2-0.1.0.0/x/test2/build/test2/test2.jsexe/index.html in browser
```

### GTK

```
cabal build
./dist-newstyle/build/x86_64-linux/ghc-8.10.7/test2-0.1.0.0/x/test2/build/test2/test2

OR

cabal run
```

## Build Project With Nix

### GTK
```
nix build
./result/bin/test2
```
