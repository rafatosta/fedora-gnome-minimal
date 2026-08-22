# Validação técnica

Registro das premissas verificadas para o Fedora GNOME Minimal.

## systemd-boot

- O Anaconda oferece `inst.sdboot` e `bootloader --sdboot`.
- Em Live installs, `systemd-boot` só pode ser usado quando a própria Live image foi construída com ele.
- O projeto portanto compõe a imagem em UEFI com `livemedia-creator --virt-uefi` e mantém uma ESP no disco temporário de build.
- O pacote Fedora `systemd-boot` é usado porque é a variante apropriada para Secure Boot; `systemd-boot-unsigned` não deve ser usado neste projeto.
- O suporte não é o padrão Fedora e é tratado pelo Anaconda como alternativa para testes/desenvolvimento. Validar novamente a cada nova versão major do Fedora.

## Anaconda WebUI e reinstalação

A WebUI permanece responsável pelo armazenamento do computador final. A opção `Reinstall Fedora` preserva a home e os dados do usuário quando exatamente uma instalação Fedora compatível é detectada e o sistema usa apenas os pontos de montagem padrão esperados pelo Anaconda.

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
