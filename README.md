# Fedora GNOME Minimal

Projeto pessoal para instalar um Fedora GNOME tradicional, mutável e reproduzível, com apenas os componentes necessários ao uso diário.

A mídia é composta seguindo o fluxo tradicional de distribuição do Fedora: **Pungi + Lorax + comps + Anaconda**, em instalação package-based.

Principais características:

- Fedora tradicional, administrado com `dnf`;
- GNOME funcional sem instalar o conjunto completo do Workstation;
- ISO de instalação completa, com repositório RPM embutido;
- Anaconda gráfico clássico;
- armazenamento decidido pelo usuário no instalador;
- `/home` existente pode ser reutilizada sem formatação pelo particionamento manual;
- `systemd-boot` no sistema final, em UEFI;
- conta `root` bloqueada;
- nenhum usuário é criado durante a instalação;
- primeiro usuário criado pelo **GNOME Initial Setup** no primeiro boot gráfico;
- NVIDIA via RPM Fusion com suporte a Secure Boot e `akmods`;
- validação e composição automatizadas com GitHub Actions.

## Estrutura

```text
.github/workflows/
  validate.yml            valida scripts, Kickstart, compose e manifests
  build-iso.yml           compõe e publica a ISO
compose/
  fedora-gnome-minimal.conf  configuração Pungi
  comps.xml                  grupo/ambiente Fedora GNOME Minimal
  variants.xml               variante x86_64 da distribuição
kickstart/
  fedora-gnome.ks          política da instalação final
packages/
  rpm.txt                  aplicativos/pacotes RPM adicionais
  flatpak.txt              aplicativos Flatpak
scripts/
  setup-repositories.sh
  setup-nvidia.sh
  install-rpm-apps.sh
  install-flatpaks.sh
  disable-services.sh
  post-install.sh
  verify.sh
build/
  build-iso.sh             executa o compose Pungi
  README.md
docs/
  CI.md
  NVIDIA-SECURE-BOOT.md
  SYSTEMD-BOOT.md
  VALIDATION.md
```

## Arquitetura da mídia

O build usa as fases documentadas do Pungi:

```text
repositórios oficiais Fedora
        ↓
      pkgset
        ↓
      gather
        ↓
    createrepo
        ↓
buildinstall / Lorax
        ↓
    createiso
        ↓
fedora-gnome-minimal.iso
```

A ISO resultante contém:

- runtime do Anaconda;
- kernel/initrd e infraestrutura de boot da mídia;
- repositório RPM da variante;
- metadata `comps` própria;
- Kickstart da instalação.

A instalação não depende de baixar o conjunto principal de RPMs pela Internet.

## Instalação e armazenamento

O Kickstart não contém `clearpart`, `autopart`, `part` ou `partition`. Assim, o Anaconda continua responsável pelo armazenamento real do computador.

Isso permite, entre outros cenários:

- usar o disco inteiro;
- usar espaço livre;
- particionamento manual;
- reutilizar uma `/home` existente sem formatá-la.

Antes de confirmar uma reinstalação manual, confira cuidadosamente quais pontos de montagem serão formatados.

## Primeiro usuário

A política é deliberadamente semelhante à experiência do Fedora Workstation:

1. a instalação termina sem criar usuário comum;
2. `root` permanece bloqueado;
3. o primeiro boot entra em `graphical.target` e inicia o GDM;
4. o `gnome-initial-setup` cria o primeiro usuário;
5. depois disso a sessão GNOME normal é iniciada.

Por isso o Kickstart não contém a diretiva `user`.

## systemd-boot

A ISO é uma mídia **package-based**, não uma Live image. O Anaconda configura o sistema final com:

```text
bootloader --sdboot
```

O bootloader da própria mídia de instalação é responsabilidade do Lorax e é independente do bootloader escolhido para o sistema instalado.

Documentação detalhada: [`docs/SYSTEMD-BOOT.md`](docs/SYSTEMD-BOOT.md).

## Gerar a mídia

O método preferencial é **Actions → Build ISO → Run workflow**.

Uma execução manual com `publish_release=true` cria uma prerelease `build-<número>` contendo:

```text
fedora-gnome-minimal.iso
fedora-gnome-minimal.iso.sha256
```

### Build local

```bash
sudo dnf install pungi lorax createrepo_c genisoimage isomd5sum
sudo bash ./build/build-iso.sh
```

A saída final será:

```text
dist/fedora-gnome-minimal.iso
```

## Pós-instalação

Depois de criar o primeiro usuário e entrar no sistema:

```bash
sudo dnf upgrade --refresh -y
sudo reboot
```

Depois:

```bash
sudo bash ./scripts/post-install.sh
```

## NVIDIA e Secure Boot

O script `scripts/setup-nvidia.sh` configura RPM Fusion e prepara o driver NVIDIA para Secure Boot usando `akmods` e uma chave MOK local.

Documentação detalhada: [`docs/NVIDIA-SECURE-BOOT.md`](docs/NVIDIA-SECURE-BOOT.md).

Para conferir o estado:

```bash
bash ./scripts/verify.sh
```

## Princípio do projeto

O sistema operacional é descartável e reproduzível. Dados pessoais devem permanecer em `/home` e em backups. Configurações que precisam sobreviver a uma reinstalação devem ser versionadas explicitamente no repositório.
