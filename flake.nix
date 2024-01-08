{
  description = "A Nix-flake-based Rust development environment";

  # GitHub URLs for the Nix inputs we're using
  inputs = {
    # Simply the greatest package repository on the planet
    nixpkgs.url = "github:NixOS/nixpkgs";
    # A set of helper functions for using flakes
    flake-utils.url = "github:numtide/flake-utils";
    # A utility library for working with Rust
    rust-overlay.url = "github:oxalica/rust-overlay";
  };

  outputs = { self, nixpkgs, flake-utils, rust-overlay }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [
          # This overlay adds the "rust-bin" package to nixpkgs
          (import rust-overlay)
        ];

        # System-specific nixpkgs with rust-overlay applied
        pkgs = import nixpkgs { inherit system overlays; };

        # Use the specific version of the Rust toolchain specified by the toolchain file
        localRust = pkgs.rust-bin.fromRustupToolchainFile ./rust-toolchain.toml;

        # Other utilities commonly used in Rust projects (but not in this example project)
        others = with pkgs; [rustup openssl pkg-config libsecret];

        NIX_LD_LIBRARY_PATH = with pkgs; pkgs.lib.makeLibraryPath [
          alsa-lib.out
          at-spi2-atk.out
          cairo.out
          cups.lib
          dbus.lib
          expat.out
          glib.out
          gtk3.out
          libdrm.out
          libxkbcommon.out
          mesa.out
          nspr.out
          nss.out
          pango.out
          xorg.libX11.out
          xorg.libXcomposite.out
          xorg.libXdamage.out
          xorg.libXext.out
          xorg.libXfixes.out
          xorg.libXrandr.out
          xorg.libxcb.out
        ];

        NIX_LD = pkgs.lib.fileContents "${pkgs.stdenv.cc}/nix-support/dynamic-linker";
      in {
        devShells = {
          default = with pkgs; mkShell {
            # Packages included in the environment
          buildInputs = [ localRust ] ++ others;


            # QT_PLUGIN_PATH = "${qt5.qtbase}/${qt5.qtbase.qtPluginPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtPluginPrefix}";
            # QML2_IMPORT_PATH = "${qt5.qtdeclarative.bin}/${qt5.qtbase.qtQmlPrefix}:${qt5.qtwayland.bin}/${qt5.qtbase.qtQmlPrefix}";

            # Run when the shell is started up
          shellHook = ''
            # Ensure cargo env file is sourced.

            export PKG_CONFIG_ALL_STATIC=1
            export PKG_CONFIG_ALLOW_CROSS=1
            export NIX_LD_LIBRARY_PATH='${NIX_LD_LIBRARY_PATH}'${"\${NIX_LD_LIBRARY_PATH:+':'}$NIX_LD_LIBRARY_PATH"}
            export NIX_LD='${NIX_LD}'
            ${localRust}/bin/cargo --version
          '';
          };
        };
      });
}
