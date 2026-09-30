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

- GNOME Calculator
- GNOME Calendar
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

### NVIDIA + Secure Boot

A instalação do driver NVIDIA é uma etapa separada e **não faz parte de `all`**:

```bash
sudo ./install.sh nvidia
```

A ação `nvidia`:

1. habilita o repositório NVIDIA disponibilizado pelo `fedora-workstation-repositories`;
2. instala `mokutil`, `akmods`, `kernel-devel-matched` e as ferramentas de assinatura;
3. gera a chave usada pelos módulos akmods, se necessário;
4. se o Secure Boot estiver ativo e a chave ainda não estiver registrada, gera uma senha temporária MOK de 8 caracteres e a exibe no terminal;
5. agenda a chave para registro no próximo boot;
6. instala `akmod-nvidia` e `xorg-x11-drv-nvidia-cuda`;
7. executa `akmods --force` para construir os módulos.

A senha MOK é mostrada apenas durante a execução e não é salva pelo script. Anote-a antes de reiniciar.

No próximo boot, quando aparecer o MOK Manager, use:

```text
Enroll MOK -> Continue -> Yes -> senha temporária -> Reboot
```

Depois do boot, a instalação pode ser verificada com:

```bash
mokutil --sb-state
nvidia-smi
```

### Instalação completa

```bash
sudo ./install.sh all
```

A opção `all` instala o GNOME mínimo, configura os repositórios de terceiros, instala os aplicativos RPM e depois os aplicativos Flatpak. **O driver NVIDIA fica propositalmente fora dessa sequência.**

## Atualizações

O projeto assume atualizações manuais, sem GNOME Software:

```bash
sudo dnf upgrade --refresh
flatpak update
```
