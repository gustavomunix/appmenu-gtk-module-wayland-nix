{ config, lib, pkgs, ... }:

let
  cfg = config.programs.appmenu-gtk-module-wayland;
  pkg = pkgs.callPackage ./package.nix { };
in
{
  options.programs.appmenu-gtk-module-wayland.enable =
    lib.mkEnableOption "módulo GTK3 de menu global (appmenu) para o Plasma Wayland";

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkg ];

    # O perfil do sistema já expõe lib/gtk-3.0 no GTK_PATH (pathsToLink),
    # então o módulo em $out/lib/gtk-3.0/modules é achado pelo nome.
    # O Plasma lê /etc/xdg/plasma-workspace/env/*.sh no começo da sessão e
    # importa as variáveis para o ambiente; o script do upstream só ativa
    # GTK_MODULES/UBUNTU_MENUPROXY quando a sessão é Wayland.
    environment.etc."xdg/plasma-workspace/env/appmenu-gtk-module-wayland.sh".source =
      "${pkg}/etc/profile.d/appmenu-gtk-module-wayland.sh";

    # Torna o schema org.appmenu.gtk-module.wayland visível para todos os
    # apps GTK sem esconder os schemas dos outros pacotes: o GLib procura
    # $XDG_DATA_DIRS/glib-2.0/schemas/gschemas.compiled.
    environment.sessionVariables.XDG_DATA_DIRS = [
      "${pkg}/share/gsettings-schemas/${pkg.name}"
    ];
  };
}
