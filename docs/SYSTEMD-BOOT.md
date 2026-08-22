# systemd-boot no Fedora GNOME Minimal

Este projeto usa `systemd-boot` de forma deliberada em vez de GRUB no sistema instalado.

## Status no Fedora

O Fedora/Anaconda oferece suporte explícito ao `systemd-boot` por meio de `inst.sdboot` e `bootloader --sdboot`, mas ele não é o bootloader padrão da distribuição. A documentação do Anaconda ainda o trata como uma alternativa que deve ser validada para a plataforma alvo.

## Arquitetura adotada

O projeto usa **instalação baseada em pacotes** a partir da Fedora Everything netinstall.

Isso é intencional: o Anaconda documenta que `inst.sdboot` funciona diretamente em instalações package-based, nas quais o bootloader pode ser escolhido no momento da instalação. Em instalações Live, essa escolha só funciona quando a própria Live foi construída com systemd-boot, o que entrou em conflito com o pipeline tradicional do Lorax usado nos primeiros protótipos deste projeto.

A arquitetura atual elimina essa ambiguidade:

1. a Fedora Everything netinstall fornece o runtime oficial do Anaconda;
2. `mkksiso` incorpora o Kickstart do projeto;
3. a linha de comando da mídia contém `inst.sdboot`;
4. o Kickstart também contém `bootloader --sdboot`;
5. o Anaconda instala os pacotes diretamente no sistema de destino e configura systemd-boot durante a própria instalação.

Não há clonagem de rootfs Live nem conversão posterior de GRUB para systemd-boot.

## WebUI e armazenamento

A mídia usa `inst.profile=fedora-workstation` e mantém a configuração de armazenamento interativa.

O Kickstart não contém `clearpart`, `autopart` ou `part`. Portanto o usuário continua escolhendo o armazenamento na WebUI, inclusive `Reinstall Fedora` quando o Anaconda detectar um layout compatível.

`inst.pauseatsummary` é incluído para exigir confirmação do usuário antes do início efetivo da instalação.

## Secure Boot

A seleção de pacotes inclui o pacote Fedora `systemd-boot`, e não `systemd-boot-unsigned`.

O Secure Boot continua sendo controlado pela UEFI do computador. Este projeto não o ativa ou desativa.

A assinatura do bootloader e a assinatura dos módulos NVIDIA são problemas distintos:

- `systemd-boot`: usa o binário Fedora assinado para Secure Boot;
- NVIDIA: usa `akmods` e a chave MOK local descrita em `NVIDIA-SECURE-BOOT.md`.

## ESP

Com `systemd-boot`, a EFI System Partition precisa ter espaço adequado para os artefatos de boot e futuras atualizações de kernel.

Para novas instalações, deixe o Anaconda criar o layout recomendado quando possível. Em reinstalações, use `Reinstall Fedora` somente quando a WebUI oferecer essa opção; caso contrário, revise os pontos de montagem manualmente.

## Verificação após a instalação

```bash
bootctl status
mokutil --sb-state
findmnt /boot/efi
```

O sistema esperado deve mostrar `systemd-boot` como boot manager e Secure Boot ativo quando habilitado no firmware.

## Fallback

Se uma versão futura do Fedora apresentar regressão de instalação/reinstalação com `systemd-boot`, o projeto deve voltar temporariamente ao bootloader padrão do Fedora em vez de improvisar uma migração no sistema em produção.
