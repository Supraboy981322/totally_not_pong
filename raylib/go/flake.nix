{
  description = "crappy pong clone in Go with Raylib-Go";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };
  outputs = { self, nixpkgs }:
    (flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in devShells.default = pkgs.mkShell ({
        packages = with pkgs; [
          go

          # Raylib-Go reps
          mesa
          libXi
          libXcursor
          libXrandr
          libglvnd
          libXinerama
          wayland
          libxkbcommon
        ];
      })
    ))
}
