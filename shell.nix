{ pkgs ? import ./. {} }:

with pkgs;

let
  root = toString ./.;
in

mkShell {
  shellHook = ''
    nixos-shell() {
      $(nix-build -A f21-nixpkgs.qemu -I nixos-config=profiles/$1 --no-out-link)/bin/run-nixos-vm
    }
  '';

  NIX_PATH = builtins.concatStringsSep ":" [
    "f21-nixpkgs=${root}"
    "nixpkgs=${root}/nixpkgs"
    "nixpkgs-overlays=${root}/overlays"
  ];
}
