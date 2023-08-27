{
  pkgs,
  fenix,
  rust-manifest,
}: let
  callPackage = pkg: pkgs.callPackage pkg;
in {
    cargo-lambda = callPackage ./cargo-lambda {
      inherit (fenix) fromManifestFile;
      inherit rust-manifest;
    };
}
