# Fedora GNOME Minimal

Configuração enxuta do GNOME sobre uma instalação **Fedora Everything**, instalando apenas o necessário para uma sessão GNOME funcional.

## Objetivo inicial

Instalar somente:

- GNOME Shell
- GDM
- Configurações do GNOME
- Nautilus
- GNOME Console
- NetworkManager
- PipeWire + WirePlumber
- Portais desktop necessários para Wayland/Flatpak
- Integrações básicas do GNOME (keyring/polkit)

Não instala, por padrão, GNOME Software, Calendário, Contatos, Mapas, Clima, Evolution ou outros aplicativos do GNOME.

## Uso

Após instalar o Fedora Everything com uma instalação base e acesso à rede:

```bash
git clone https://github.com/rafatosta/fedora-gnome-minimal.git
cd fedora-gnome-minimal
chmod +x install.sh
sudo ./install.sh
```

Ao final, reinicie o sistema:

```bash
sudo reboot
```

## Atualizações

O projeto assume atualizações manuais:

```bash
sudo dnf upgrade --refresh
flatpak update
```

O GNOME Software não faz parte da instalação mínima.
