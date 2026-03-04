{
  description = "Python dev environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
    esp-dev.url = "github:mirrexagon/nixpkgs-esp-dev";
  };

  outputs = { self, nixpkgs, flake-utils, esp-dev }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        openglDriverLibs =
          [ "/run/opengl-driver/lib" "/run/opengl-driver-32/lib" ];
        runtimeLibs = with pkgs; [
          stdenv.cc.cc.lib
          zlib
          glib
          libGL
          ffmpeg
          xorg.libxcb
          xorg.libX11
          xorg.libXext
          xorg.libXrender
          xorg.libSM
        ];
      in {
        devShells.default = pkgs.mkShell {
          inputsFrom = [ esp-dev.devShells.${system}.esp-idf-full ];
          packages = with pkgs; [ uv patchelf ];
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath runtimeLibs}:${
              pkgs.lib.concatStringsSep ":" openglDriverLibs
            }";
        };
      });
}
