final: previous:

with final;
with lib;
let 
  cargo-to-nix = fetchFromGitHub {
    owner = "Holo-Host";
    repo = "cargo-to-nix";
    rev = "ba6adc0a075dfac2234e851b0d4c2511399f2ef0";
    sha256 = "1rcwpaj64fwz1mwvh9ir04a30ssg35ni41ijv9bq942pskagf1gl";
  };
in
{

   nixpkgs-mozilla = fetchTarball {
    url = "https://github.com/mozilla/nixpkgs-mozilla/archive/dea7b9908e150a08541680462fe9540f39f2bceb.tar.gz";
    sha256 = "0kvwbnwxbqhc3c3hn121c897m89d9wy02s8xcnrvqk9c96fj83qw";
  };
  inherit (callPackage "${nixpkgs-mozilla}/package-set.nix" {}) rustChannelOf;
  inherit (callPackage cargo-to-nix {})
    buildRustPackage
    cargoToNix
  ;
  rust = previous.rust // {
    packages = previous.rust.packages // {
      nightly = {
        rustPlatform = final.makeRustPlatform {
          inherit (buildPackages.rust.packages.nightly) cargo rustc;
        };

        cargo = final.rust.packages.nightly.rustc;
        rustc = (
          rustChannelOf {
            channel = "nightly";
            date = "2019-11-16";
            sha256 = "17l8mll020zc0c629cypl5hhga4hns1nrafr7a62bhsp4hg9vswd";
          }
        ).rust.override {
          targets = [
            "aarch64-unknown-linux-musl"
            "wasm32-unknown-unknown"
            "x86_64-pc-windows-gnu"
            "x86_64-unknown-linux-musl"
          ];
        };
      };
    };
  };
  buildImage = imports:
    let
      system = nixos {
        inherit imports;
      };

      imageNames = filter (name: hasAttr name system) [
        "isoImage"
        "sdImage"
        "virtualBoxOVA"
        "vm"
      ];
    in
    head (attrVals imageNames system);

  example = callPackage ./example {};

  example-nixpkgs = recurseIntoAttrs {
    profile = tryDefault <nixos-config> ../../profiles;

    qemu = buildImage [
      ../../profiles/hardware/qemu
      example-nixpkgs.profile
    ];
  };

  tryDefault = x: default:
    let
      eval = builtins.tryEval x;
    in
    if eval.success then eval.value else default;
}
