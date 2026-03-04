{
  description = "Python dev environment with uv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils, }:
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
          packages = with pkgs; [ uv patchelf ];
          LD_LIBRARY_PATH = "${pkgs.lib.makeLibraryPath runtimeLibs}:${
              pkgs.lib.concatStringsSep ":" openglDriverLibs
            }";
        };
      });
}
