# Validação técnica

Registro das premissas do Fedora GNOME Minimal.

## Compose da distribuição

- Pungi é usado para organizar a composição da distribuição.
- `pkgset_source = "repos"` permite consumir repositórios Yum/DNF arbitrários; o projeto usa os repositórios oficiais do Fedora.
- `comps.xml` define o grupo/ambiente de software da variante.
- `variants.xml` limita a distribuição à variante Fedora GNOME Minimal em x86_64.
- `gather` resolve dependências, `createrepo` gera o repositório da variante, `buildinstall` chama Lorax e `createiso` produz a mídia bootável completa.
- A ISO final é package-based e contém o repositório RPM; não é Live nem netinstall modificada.

## systemd-boot

- O Anaconda oferece `bootloader --sdboot` para instalações package-based.
- A escolha do bootloader do sistema final é independente da infraestrutura de boot usada pelo Lorax na própria ISO.
- O pacote `systemd-boot` é incluído no ambiente; `systemd-boot-unsigned` não é usado.
- O suporte deve ser revalidado a cada versão major do Fedora.

## Armazenamento

- O Kickstart não contém `clearpart`, `autopart`, `part` ou `partition`.
- O Anaconda gráfico clássico continua responsável pelo armazenamento.
- Uma `/home` existente pode ser atribuída manualmente sem formatação.
- Toda reinstalação deve revisar explicitamente os pontos de montagem e flags de formatação antes da confirmação.

## Primeiro usuário

- O Kickstart mantém `rootpw --lock`.
- Não existe diretiva `user`.
- O ambiente inclui `gdm`, GNOME e `gnome-initial-setup`.
- O sistema final usa `graphical.target` e GDM.
- O resultado esperado é o GNOME Initial Setup criar o primeiro usuário no primeiro boot gráfico, em vez de a instalação criar uma conta temporária.

## Secure Boot e NVIDIA

A cadeia do bootloader e a assinatura dos módulos NVIDIA são independentes:

- systemd-boot usa o binário fornecido pelo Fedora;
- NVIDIA usa `akmods` e MOK local;
- a inscrição da MOK permanece interativa no reboot.

## Verificação pós-instalação

Depois que o primeiro usuário for criado:

```bash
bootctl status
mokutil --sb-state
findmnt /boot/efi
nvidia-smi
modinfo -F signer nvidia
```
