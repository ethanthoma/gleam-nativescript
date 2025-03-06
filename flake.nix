{
  description = "A very basic flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    nix-gleam.url = "github:arnarg/nix-gleam";
    android.url = "github:tadfisher/android-nixpkgs";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
      nix-gleam,
      android,
      nix-ld,
    }:
    {
      overlays.default = nixpkgs.lib.composeManyExtensions [
        nix-gleam.overlays.default
      ];
    }
    // flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = nixpkgs.legacyPackages.${system}.extend self.overlays.default;

        android-sdk = android.sdk.${system} (
          sdkPkgs: with sdkPkgs; [
            build-tools-34-0-0
            cmdline-tools-latest
            emulator
            platform-tools
            platforms-android-34
          ]
        );
      in
      {
        devShells.default = pkgs.mkShell {
          env = {
            ANDROID_HOME = "${android-sdk}/share/android-sdk";
            ANDROID_SDK_ROOT = "${android-sdk}/share/android-sdk";
            JAVA_HOME = pkgs.jdk.home;
            GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=${android-sdk}/share/android-sdk/build-tools/34.0.0/aapt2";
          };

          packages = [
            pkgs.gleam
            pkgs.nodejs_23
            pkgs.jdk
            android-sdk
            pkgs.glibc

            pkgs.oxlint
            pkgs.biome
          ];

          shellHook = ''
            mkdir -p cache_dir
            npm config set prefix cache_dir
            npm install -g nativescript
            export PATH="$PATH:cache_dir/bin"
          '';
        };
      }
    );
}
