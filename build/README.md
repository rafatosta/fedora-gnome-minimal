# Geração da mídia de instalação

A mídia do Fedora GNOME Minimal é derivada da **Fedora Everything netinstall** com `mkksiso`, do Lorax. O projeto não usa mais `livemedia-creator` nem instala a partir de uma imagem Live clonada.

A instalação final é **baseada em pacotes**, requisito importante para que o Anaconda possa selecionar `systemd-boot` no momento da instalação por meio de `inst.sdboot` / `bootloader --sdboot`.

## Dependências

```bash
sudo dnf install lorax
```

## ISO fonte

Use a Fedora Everything netinstall x86_64 da mesma versão alvo do projeto.

## Gerar

```bash
sudo FEDORA_RELEASE=44 bash ./build/build-iso.sh ~/Downloads/Fedora-Everything-netinst-x86_64.iso
```

A saída final será:

```text
dist/fedora-gnome-minimal.iso
```

O log do `mkksiso` fica em:

```text
dist/mkksiso.log
```

## Como funciona

`mkksiso` preserva o runtime oficial do Anaconda e a estrutura de boot da Fedora Everything, incorpora `kickstart/fedora-gnome.ks` e acrescenta à linha de comando do instalador:

```text
inst.sdboot
inst.profile=fedora-workstation
inst.pauseatsummary
inst.repo=<árvore Fedora Everything>
```

O Kickstart define a seleção de pacotes e `bootloader --sdboot`, mas não contém `clearpart`, `autopart` ou `part`. Assim, a configuração de armazenamento continua sendo feita pelo usuário na WebUI.

## Rede

A ISO é uma mídia **netinstall**: os pacotes do sistema são obtidos do repositório Fedora Everything durante a instalação. Por padrão o script usa:

```text
https://download.fedoraproject.org/pub/fedora/linux/releases/<versão>/Everything/x86_64/os/
```

Para usar outro mirror ou uma árvore Fedora compatível:

```bash
sudo INSTALL_REPO_URL=https://servidor/exemplo/os/ \
  FEDORA_RELEASE=44 \
  bash ./build/build-iso.sh Fedora-Everything-netinst.iso
```

## systemd-boot

O sistema final é instalado diretamente com `systemd-boot`; não há conversão pós-instalação e não há dependência do bootloader da mídia para definir o bootloader do sistema alvo. Consulte `docs/SYSTEMD-BOOT.md`.
