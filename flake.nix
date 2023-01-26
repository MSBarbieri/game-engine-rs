{
  inputs = {
    naersk.url = "github:nix-community/naersk/master";
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    utils.url = "github:numtide/flake-utils";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, utils, naersk, fenix }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { 
          inherit system;
          overlays = [
            fenix.overlays.default 
          ];
        };
        naersk-lib = pkgs.callPackage naersk { };
      in
      {
        defaultPackage = naersk-lib.buildPackage {
          src = ./.;
          buildInputs = with pkgs; [ 
            cmake
            fontconfig
            pkg-config
            gnumake
            xorg.libX11.dev
            xorg.libXft
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            xorg.libXinerama
          ];
          RUST_LOG = "trace";
        };
        devShell = with pkgs; mkShell {
          buildInputs = [ 
              (pkgs.fenix.complete.withComponents [
              "cargo"
              "clippy"
              "rust-src"
              "rustc"
              "rustfmt"
            ])
            cmake 
            fontconfig
            gnumake
            xorg.libX11.dev
            xorg.libXft
            xorg.libXcursor
            xorg.libXrandr
            xorg.libXi
            xorg.libXinerama
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          nativeBuildInputs = [pkgs.pkg-config];
          RUST_LOG = "debug";
          # RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
        };
      });
}
