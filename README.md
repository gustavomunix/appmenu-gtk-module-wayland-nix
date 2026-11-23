# appmenu-gtk-module-wayland-nix

Flake que empacota o [appmenu-gtk-module-wayland](https://github.com/guiodic/appmenu-gtk-module-wayland) — módulo GTK3 que exporta os menus dos aplicativos GTK para o menu global do KDE Plasma 6 no Wayland (e no X11, mas o foco é Wayland).

## Uso como módulo NixOS

```nix
{
  inputs.appmenu = {
    url = "github:SEU_USUARIO/appmenu-gtk-module-wayland-nix";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, appmenu, ... }: {
    nixosConfigurations.minha-maquina = nixpkgs.lib.nixosSystem {
      modules = [
        appmenu.nixosModules.default
        {
          programs.appmenu-gtk-module-wayland.enable = true;
        }
      ];
    };
  };
}
```

O módulo faz três coisas:

- instala o pacote em `environment.systemPackages`; o `.so` fica em `lib/gtk-3.0/modules`, que o perfil do sistema já expõe via `GTK_PATH`;
- instala o script de sessão do upstream em `/etc/xdg/plasma-workspace/env/`. O Plasma lê esses scripts no início da sessão, e o script só define `GTK_MODULES`/`UBUNTU_MENUPROXY` quando `XDG_SESSION_TYPE=wayland` (ou `WAYLAND_DISPLAY` está definido);
- adiciona o diretório do schema GSettings em `XDG_DATA_DIRS`, então `gsettings` e os apps GTK encontram `org.appmenu.gtk-module.wayland` sem esconder os outros schemas.

Depois de ativar a config, saia e entre de novo na sessão Plasma Wayland (reiniciar só os apps GTK também resolve).

## Configuração

```sh
gsettings list-recursively org.appmenu.gtk-module.wayland
gsettings set org.appmenu.gtk-module.wayland always-show-inner-menu true
```

- `blacklist` / `whitelist`: nomes de programa (`g_get_prgname()`) onde o módulo fica desligado/ligado.
- `run-on-wayland`: permite o módulo em apps Wayland nativos (padrão `true`).
- `always-show-inner-menu`: mantém o menu dentro da janela mesmo com o registrar/Plasma disponível.

`UBUNTU_MENUPROXY=0` continua desligando o módulo para um app específico. Reinicie o app depois de mudar `blacklist`, `whitelist` ou `run-on-wayland`.

## Pacote avulso

```sh
nix build github:SEU_USUARIO/appmenu-gtk-module-wayland-nix
```

O resultado tem:

```
$out/lib/gtk-3.0/modules/libappmenu-gtk-module-wayland.so
$out/etc/profile.d/appmenu-gtk-module-wayland.sh
$out/share/gsettings-schemas/appmenu-gtk-module-wayland-*/glib-2.0/schemas/
```

Ativação manual numa sessão Wayland:

```sh
export GTK_PATH=$out/lib/gtk-3.0:$GTK_PATH
export GTK_MODULES=appmenu-gtk-module-wayland:${GTK_MODULES:-}
```

## Overlay

```nix
{
  nixpkgs.overlays = [ inputs.appmenu.overlays.default ];
  environment.systemPackages = [ pkgs.appmenu-gtk-module-wayland ];
}
```

O overlay só fornece o pacote; a ativação (script de sessão + schema) fica por sua conta.

## Detalhes do empacotamento

- Build via CMake do upstream, com `GTK_MODULE_INSTALL_DIR` no default (`lib/gtk-3.0/modules`) e o script indo para `$out/etc/profile.d` em vez de `/etc/profile.d`.
- `glib.dev` entra em `nativeBuildInputs` porque neste nixpkgs o `glib-compile-schemas` está no output `dev`.
- O schema é compilado no `postInstall`; o setup hook do glib depois o move para `share/gsettings-schemas/<nome>/glib-2.0/schemas`, que é o layout esperado pelo `wrapGAppsHook`.
- Não instala a unit systemd opcional do upstream: no Plasma a ativação confiável é o script de ambiente da sessão.

## Atualizar o upstream

```sh
cd appmenu-gtk-module-wayland-nix
nix flake update          # atualiza nixpkgs
# depois troque rev/hash em package.nix:
nix-prefetch-url --unpack https://github.com/guiodic/appmenu-gtk-module-wayland/archive/<rev>.tar.gz
nix hash convert --hash-algo sha256 --to sri <hash-base32>
```
