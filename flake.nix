{
  description = "Nix packaging for appmenu-gtk-module-wayland (GTK app menu on Plasma Wayland)";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: {
        default = pkgs.callPackage ./package.nix { };
        appmenu-gtk-module-wayland = self.packages.${pkgs.stdenv.hostPlatform.system}.default;
      });

      overlays.default = final: _prev: {
        appmenu-gtk-module-wayland = final.callPackage ./package.nix { };
      };

      nixosModules = {
        default = ./module.nix;
        appmenu-gtk-module-wayland = ./module.nix;
      };
    };
}
