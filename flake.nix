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

        desktop-command = pkgs.writeShellScriptBin "desktop" ''
          #!/bin/bash
          cargo run --bin desktop
        '';

        web-command = pkgs.writeShellScriptBin "desktop" ''
          #!/bin/bash
          cargo run --bin web
        '';
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
            desktop-command
            web-command
            vulkan-headers
            vulkan-loader
            vulkan-tools
          ];
          RUST_SRC_PATH = rustPlatform.rustLibSrc;
          nativeBuildInputs = [pkgs.pkg-config];
          RUST_LOG = "debug";
          LD_LIBRARY_PATH="${vulkan-loader}/lib";
          # RUSTC_VERSION = pkgs.lib.readFile ./rust-toolchain;
        };
      });
}
