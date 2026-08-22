# Geração da mídia Live

A mídia do Fedora GNOME Minimal é construída com `livemedia-creator`, do Lorax. O objetivo é gerar uma **imagem Live própria** contendo GNOME + Anaconda WebUI, preservando a experiência de instalação moderna do Fedora Workstation.

A imagem é construída em **UEFI** e usa `systemd-boot` em vez de GRUB como bootloader alvo.

## Dependências

```bash
sudo dnf install lorax lorax-lmc-virt
```

O build usa `livemedia-creator --virt-uefi`, necessário porque `systemd-boot` é UEFI-only. O script também verifica a presença do firmware EDK2 em `/usr/share/edk2`.

## ISO fonte

Use uma ISO Fedora Everything/netinstall compatível com a versão alvo.

## Gerar

```bash
sudo bash ./build/build-iso.sh ~/Downloads/Fedora-Everything-netinst-x86_64.iso
```

A saída final será:

```text
dist/fedora-gnome-minimal.iso
```

Os artefatos e logs intermediários ficam em:

```text
dist/lmc/
```

## Partições usadas durante o build

O Kickstart cria somente no disco virtual temporário da composição:

- uma ESP de 1 GiB em `/boot/efi`;
- uma raiz ext4 temporária para construir a imagem Live.

Essas partições não são impostas ao computador final.

## Instalação no computador

A WebUI do Anaconda continua responsável pelo armazenamento real e apresenta os cenários disponíveis, como usar o disco inteiro, usar espaço livre, atribuir pontos de montagem ou `Reinstall Fedora` quando o layout detectado satisfaz os critérios do Anaconda.

## systemd-boot

O Kickstart contém `bootloader --sdboot` e instala o pacote Fedora `systemd-boot`, apropriado para Secure Boot. O suporte existe no Anaconda, mas não é o padrão Fedora e ainda é descrito upstream como alternativa para testes/desenvolvimento. Consulte `docs/SYSTEMD-BOOT.md` e `docs/VALIDATION.md` ao migrar o projeto para uma nova versão major do Fedora.
