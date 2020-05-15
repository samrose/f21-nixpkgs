{ config, lib, pkgs, ... }:

{
  imports = [ ../modules ];
  nixpkgs.overlays = [ (import ../overlays/f21-nixpkgs) ];
  environment.systemPackages = [ pkgs.git ];
  services.mingetty.autologinUser = "root";
  services.example.enable = true;
}

