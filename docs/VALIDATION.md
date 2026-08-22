# Validação técnica

Registro das premissas verificadas para o Fedora GNOME Minimal.

## systemd-boot

- O Anaconda oferece `inst.sdboot` e `bootloader --sdboot`.
- A documentação do Anaconda informa que `inst.sdboot` funciona diretamente em instalações **baseadas em pacotes**, nas quais o bootloader pode ser escolhido no momento da instalação.
- Em Live installs, `systemd-boot` só pode ser usado quando a própria Live image foi construída com ele em vez de GRUB.
- Os protótipos Live deste projeto conseguiram gerar e iniciar a mídia, mas a instalação final continuou criando uma entrada UEFI para shim/GRUB. Por isso a arquitetura Live foi abandonada.
- A arquitetura atual usa Fedora Everything netinstall + `mkksiso`, com `inst.sdboot` na linha de comando e `bootloader --sdboot` no Kickstart.
- O pacote Fedora `systemd-boot` é usado porque é a variante apropriada para Secure Boot; `systemd-boot-unsigned` não deve ser usado neste projeto.
- O suporte não é o padrão Fedora e deve ser validado novamente a cada nova versão major do Fedora.

## Package-based / netinstall

- A mídia preserva o runtime oficial da Fedora Everything netinstall.
- `mkksiso` incorpora o Kickstart e atualiza as configurações de boot da ISO, inclusive a imagem EFI embutida quando executado com os privilégios necessários.
- A instalação baixa os pacotes da árvore Fedora Everything; portanto conectividade de rede faz parte dos requisitos da mídia atual.
- O Kickstart não contém comandos de particionamento, para que a configuração de armazenamento continue interativa.
- `inst.pauseatsummary` é usado para impedir início automático antes da confirmação final do usuário.

## Anaconda WebUI e reinstalação

A mídia solicita o perfil `fedora-workstation` por `inst.profile=fedora-workstation` para manter o comportamento e a experiência da WebUI associados ao Workstation.

A WebUI permanece responsável pelo armazenamento do computador final. A opção `Reinstall Fedora` preserva a home e os dados do usuário quando uma instalação Fedora compatível é detectada e o layout satisfaz os critérios do Anaconda.

O projeto não presume que essa opção estará sempre disponível. Se a WebUI não a oferecer, a reinstalação deve ser feita por atribuição manual de pontos de montagem com revisão cuidadosa antes de formatar qualquer volume.

## Secure Boot e NVIDIA

A cadeia do bootloader e a assinatura dos módulos NVIDIA são independentes:

- `systemd-boot` usa o binário assinado fornecido pelo Fedora;
- módulos NVIDIA são compilados pelo `akmods` e assinados com a chave MOK local;
- a inscrição inicial da chave MOK continua sendo confirmada interativamente no reboot.

## Verificação pós-instalação

```bash
bootctl status
mokutil --sb-state
findmnt /boot/efi
nvidia-smi
modinfo -F signer nvidia
```
