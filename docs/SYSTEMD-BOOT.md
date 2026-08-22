# systemd-boot no Fedora GNOME Minimal

O projeto usa `systemd-boot` no sistema instalado, embora ele não seja o bootloader padrão do Fedora.

## Arquitetura

A mídia é uma ISO de instalação **package-based** criada por Pungi + Lorax. Isso separa corretamente dois problemas:

- o boot da própria ISO é produzido pelo Lorax;
- o bootloader do sistema final é escolhido pelo Anaconda durante a instalação.

O Kickstart contém:

```text
bootloader --sdboot
```

Como não se trata de uma Live image, não existe clonagem de rootfs nem necessidade de fazer systemd-boot sobreviver a uma segunda instalação.

## Armazenamento

O Kickstart não define particionamento. O Anaconda clássico continua responsável por selecionar disco, criar um layout novo ou reutilizar pontos de montagem existentes.

Ao preservar `/home`, atribua o ponto de montagem existente e confirme que ele **não** está marcado para formatação.

## Secure Boot

O conjunto da distribuição inclui o pacote Fedora `systemd-boot`, não `systemd-boot-unsigned`.

A cadeia do bootloader é independente da assinatura dos módulos NVIDIA:

- systemd-boot: binário fornecido pelo Fedora;
- NVIDIA: módulos externos assinados localmente pelo `akmods` com MOK.

## Verificação pós-instalação

Depois que o primeiro usuário for criado pelo GNOME Initial Setup:

```bash
bootctl status
mokutil --sb-state
findmnt /boot/efi
```

O resultado esperado é `systemd-boot` como boot manager do sistema instalado.

## Compatibilidade

O suporte do Anaconda a systemd-boot deve ser revalidado em cada versão major do Fedora. Se houver regressão, o projeto deve preferir temporariamente o bootloader padrão do Fedora em vez de aplicar conversões pós-instalação não suportadas.
