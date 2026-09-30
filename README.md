# Fedora GNOME Minimal

Configuração enxuta do GNOME sobre uma instalação **Fedora Everything**, instalando apenas o necessário para uma sessão GNOME funcional e, opcionalmente, os aplicativos de terceiros já utilizados no ambiente pessoal.

## GNOME mínimo

Instala somente:

- GNOME Shell
- GDM
- Configurações do GNOME
- Nautilus
- GNOME Console
- NetworkManager
- PipeWire + WirePlumber
- Portais desktop necessários para Wayland/Flatpak
- GNOME Keyring / Polkit
- suporte básico a volumes, MTP e câmeras

Não instala, por padrão, GNOME Software, Calendário, Contatos, Mapas, Clima, Evolution ou outros aplicativos do GNOME.

## Aplicativos de terceiros

### RPM / repositórios próprios

- Google Chrome
- Visual Studio Code
- ChatGPT

Os repositórios correspondentes são configurados pelo próprio projeto antes da instalação.

### Flatpak / Flathub

- Dialect
- Obfuscate
- Boxy SVG
- Flatseal
- Extension Manager
- ZapZap
- Spotify
- Varia
- Desktop Plus
- Resources
- Gaphor
- ONLYOFFICE Desktop Editors
- VLC
- Virtual Machine Manager
- Refine
- Flatpak Builder
- Apostrophe
- Steam

A lista foi trazida do repositório pessoal `postinstall-fedora` para manter o novo projeto compatível com os aplicativos já utilizados.

## Uso

Após instalar o Fedora Everything com uma instalação base e acesso à rede:

```bash
git clone https://github.com/rafatosta/fedora-gnome-minimal.git
cd fedora-gnome-minimal
chmod +x install.sh
```

### Somente GNOME mínimo

```bash
sudo ./install.sh
```

ou:

```bash
sudo ./install.sh gnome
```

### Aplicativos RPM de terceiros

```bash
sudo ./install.sh apps
```

### Aplicativos Flatpak

```bash
sudo ./install.sh flatpaks
```

### Instalação completa

```bash
sudo ./install.sh all
```

A opção `all` instala o GNOME mínimo, configura os repositórios de terceiros, instala os aplicativos RPM e depois os aplicativos Flatpak.

## Atualizações

O projeto assume atualizações manuais, sem GNOME Software:

```bash
sudo dnf upgrade --refresh
flatpak update
```
