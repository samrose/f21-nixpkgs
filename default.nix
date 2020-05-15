{ ... } @ args: import (import ./vendor/nixpkgs.nix) (args // {
  overlays = [ (import ./overlays/f21-nixpkgs) ] ++ (args.overlays or []);
})
