{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.programs.appmenu-gtk-module-wayland;
  schemaDir = "${cfg.package}/share/gsettings-schemas/${cfg.package.name}";
  gtkModuleDir = "${cfg.package}/lib/gtk-3.0";
in
{
  options.programs.appmenu-gtk-module-wayland = {
    enable = lib.mkEnableOption "módulo GTK3 de menu global (appmenu) para o Plasma Wayland";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.callPackage ./package.nix { };
      defaultText = lib.literalExpression "pkgs.callPackage ./package.nix { }";
      description = "Pacote appmenu-gtk-module-wayland a instalar.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment = {
      systemPackages = [ cfg.package ];
      pathsToLink = [ "/lib/gtk-3.0" ];

      # O Plasma lê /etc/xdg/plasma-workspace/env/*.sh no começo da sessão.
      # O script do upstream só ativa GTK_MODULES/UBUNTU_MENUPROXY no Wayland;
      # também adicionamos o diretório do módulo em GTK_PATH e o schema em
      # XDG_DATA_DIRS preservando os valores existentes da sessão.
      etc."xdg/plasma-workspace/env/appmenu-gtk-module-wayland.sh".text = ''
        . "${cfg.package}/etc/profile.d/appmenu-gtk-module-wayland.sh"
        case ":''${GTK_PATH:-}:" in
          *:"${gtkModuleDir}":*) ;;
          *) export GTK_PATH="${gtkModuleDir}''${GTK_PATH:+:$GTK_PATH}" ;;
        esac
        case ":''${XDG_DATA_DIRS:-}:" in
          *:"${schemaDir}":*) ;;
          *) export XDG_DATA_DIRS="${schemaDir}:''${XDG_DATA_DIRS:-/usr/local/share:/usr/share}" ;;
        esac
      '';
    };
  };
}
