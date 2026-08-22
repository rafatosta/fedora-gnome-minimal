# systemd-boot no Fedora GNOME Minimal

Este projeto usa `systemd-boot` de forma deliberada em vez de GRUB no sistema instalado.

## Status no Fedora

O Fedora/Anaconda oferece suporte explícito ao `systemd-boot` por meio de `inst.sdboot` e `bootloader --sdboot`, mas ele não é o bootloader padrão da distribuição. A documentação do Anaconda ainda o classifica como uma alternativa voltada a testes/desenvolvimento. Portanto, esta é uma escolha específica deste projeto e deve ser validada a cada nova versão do Fedora antes de uma reinstalação real.

## Por que usar

O alvo deste projeto é um computador moderno, UEFI, com Secure Boot e apenas Fedora como sistema principal. Nesse cenário, `systemd-boot` reduz a complexidade do caminho de inicialização e combina com a proposta de uma instalação mínima e reproduzível.

## Live ISO e Anaconda WebUI

O Anaconda documenta que `inst.sdboot` funciona diretamente em instalações baseadas em pacotes. Para instalações a partir de Live image, o `systemd-boot` só pode ser usado se a própria imagem Live tiver sido construída com `systemd-boot` em vez de GRUB.

Por isso o Kickstart de composição contém:

```text
bootloader --sdboot
```

A construção também é executada em UEFI (`livemedia-creator --virt-uefi`) e o disco temporário usado na composição possui uma ESP dedicada.

Essas diretivas se aplicam ao ambiente temporário de construção da Live ISO. Na instalação final, a WebUI do Anaconda continua responsável pelo armazenamento e pode oferecer `Reinstall Fedora` quando detectar um layout Fedora compatível.

## Secure Boot

A imagem instala o pacote Fedora `systemd-boot`, e não `systemd-boot-unsigned`. O pacote assinado é o apropriado para máquinas com Secure Boot.

O Secure Boot continua sendo controlado pela UEFI do computador. Este projeto não o ativa ou desativa.

A assinatura do bootloader e a assinatura dos módulos NVIDIA são problemas distintos:

- `systemd-boot`: usa o binário Fedora assinado para Secure Boot;
- NVIDIA: usa `akmods` e a chave MOK local descrita em `NVIDIA-SECURE-BOOT.md`.

## ESP

Com `systemd-boot`, kernels, initramfs e arquivos de boot ficam associados à EFI System Partition. O Anaconda alerta que a ESP precisa ter espaço suficiente para futuras atualizações de kernel.

Para novas instalações, deixe o Anaconda criar o layout recomendado pelo Fedora. Em reinstalações, use `Reinstall Fedora` somente quando a WebUI oferecer essa opção; caso contrário, revise os pontos de montagem manualmente e confirme que a ESP existente tem espaço adequado.

## Verificação após a instalação

```bash
bootctl status
mokutil --sb-state
findmnt /boot/efi
```

O sistema esperado deve mostrar `systemd-boot` como boot manager e Secure Boot ativo quando habilitado no firmware.

## Fallback

Se uma versão futura do Fedora apresentar regressão de instalação/reinstalação com `systemd-boot`, o projeto deve voltar temporariamente ao bootloader padrão do Fedora em vez de improvisar uma migração no sistema em produção.
