# Fedora GNOME Minimal

Projeto pessoal para instalar um Fedora GNOME tradicional, mutável e reproduzível, com apenas os componentes necessários ao uso diário.

A proposta é substituir o modelo "instalar Fedora Workstation completo e depois remover coisas" por uma mídia própria baseada na Fedora Everything netinstall, mantendo a experiência moderna de instalação do Fedora Workstation:

- Fedora tradicional, administrado com `dnf`;
- GNOME funcional, sem depender do conjunto completo do Workstation;
- instalação **baseada em pacotes**;
- **Anaconda WebUI** com perfil Workstation;
- armazenamento decidido pelo usuário no instalador;
- possibilidade de `Reinstall Fedora` quando o layout existente é compatível, preservando `/home` e dados pessoais;
- `systemd-boot` em UEFI, em vez de GRUB, como escolha deliberada do projeto;
- Secure Boot suportado com o pacote Fedora assinado `systemd-boot`;
- pacotes RPM essenciais definidos em arquivo;
- aplicativos Flatpak definidos em arquivo;
- NVIDIA via RPM Fusion com suporte a Secure Boot e assinatura automática por `akmods`;
- serviços não utilizados desabilitados de forma defensiva;
- validação e geração da ISO automatizadas com GitHub Actions.

## Estrutura

```text
.github/workflows/
  validate.yml            valida scripts, Kickstart e manifests
  build-iso.yml           gera e publica a ISO sob demanda ou por tag
kickstart/
  fedora-gnome.ks         seleção de pacotes e configuração da instalação final
packages/
  rpm.txt                 aplicativos/pacotes RPM adicionais
  flatpak.txt             aplicativos Flatpak
scripts/
  setup-repositories.sh   repositórios de terceiros
  setup-nvidia.sh         RPM Fusion, NVIDIA, akmods e Secure Boot
  install-rpm-apps.sh     instalação dos RPMs adicionais
  install-flatpaks.sh     configuração do Flathub e Flatpaks
  disable-services.sh     serviços não utilizados
  post-install.sh         orquestrador pós-instalação
  verify.sh               checagem rápida do ambiente
build/
  build-iso.sh            deriva a mídia da Fedora Everything usando mkksiso
  README.md               instruções de geração da mídia
docs/
  CI.md                   GitHub Actions, releases e fluxo de testes
  NVIDIA-SECURE-BOOT.md   fluxo detalhado do driver NVIDIA e MOK
  SYSTEMD-BOOT.md         arquitetura, Secure Boot e limitações do systemd-boot
  VALIDATION.md           premissas técnicas validadas para o projeto
```

## Instalação e recuperação

O Kickstart deste repositório é executado pelo Anaconda durante a instalação final, mas **não define o particionamento**. Ele controla principalmente a seleção de pacotes e o bootloader.

Ao iniciar a mídia, a instalação acontece pela WebUI do Anaconda. As decisões de armazenamento permanecem interativas, incluindo os cenários oferecidos pelo instalador quando aplicáveis:

- usar o disco inteiro;
- usar espaço livre;
- atribuir pontos de montagem manualmente;
- **Reinstall Fedora**, quando uma instalação Fedora compatível é detectada.

A opção `Reinstall Fedora` é especialmente importante para este projeto: ela permite reconstruir o sistema mantendo a home e os dados pessoais quando o layout existente atende aos critérios do Anaconda.

## systemd-boot

O projeto usa `systemd-boot` no sistema instalado. Essa não é a configuração padrão do Fedora.

A mídia é package-based porque o Anaconda suporta a escolha do bootloader no momento da instalação nesse modo. O build incorpora:

```text
inst.sdboot
```

na linha de comando do instalador, e o Kickstart contém:

```text
bootloader --sdboot
```

Isso evita a incompatibilidade observada nos primeiros protótipos baseados em Live image, nos quais a mídia final ainda dependia da infraestrutura GRUB do Lorax.

Documentação detalhada: [`docs/SYSTEMD-BOOT.md`](docs/SYSTEMD-BOOT.md).

## Gerar a mídia

O método preferencial é o GitHub Actions. Em **Actions → Build ISO → Run workflow**, mantenha os valores padrão para Fedora 44 e execute o job.

Por padrão, uma execução manual bem-sucedida cria uma prerelease `build-<número>` contendo:

```text
fedora-gnome-minimal.iso
fedora-gnome-minimal.iso.sha256
```

O workflow baixa a Fedora Everything netinstall oficial, valida o SHA-256 e usa `mkksiso` para incorporar o Kickstart e os argumentos do Anaconda. Não há criação de VM nem `livemedia-creator` no build atual.

A mídia é netinstall: os pacotes são obtidos da árvore Fedora Everything durante a instalação. O workflow permite substituir a URL do repositório quando necessário.

Tags `v*`, por exemplo `v44.1`, também disparam o build e publicam a ISO na Release correspondente.

Documentação completa: [`docs/CI.md`](docs/CI.md).

### Build local opcional

```bash
sudo dnf install lorax
sudo FEDORA_RELEASE=44 bash ./build/build-iso.sh /caminho/Fedora-Everything-netinst.iso
```

A saída será:

```text
dist/fedora-gnome-minimal.iso
```

## Pós-instalação

Depois da primeira inicialização do sistema instalado, aplique todas as atualizações e reinicie antes de instalar os módulos externos:

```bash
sudo dnf upgrade --refresh -y
sudo reboot
```

Depois:

```bash
sudo bash ./scripts/post-install.sh
```

## NVIDIA e Secure Boot

O script `scripts/setup-nvidia.sh` configura RPM Fusion e prepara o driver NVIDIA para funcionar com Secure Boot.

Na primeira instalação com Secure Boot ativo, pode ser necessário criar uma senha temporária para importar a chave. No reboot seguinte, confirme a inscrição no MokManager usando essa senha.

Depois que a chave é inscrita, atualizações futuras de kernel ou do driver são tratadas pelo `akmods`, que recompila e assina os módulos NVIDIA automaticamente com a mesma chave.

Documentação detalhada: [`docs/NVIDIA-SECURE-BOOT.md`](docs/NVIDIA-SECURE-BOOT.md).

Para conferir o estado:

```bash
bash ./scripts/verify.sh
```

## Princípio do projeto

O sistema operacional é descartável e reproduzível. Dados pessoais devem permanecer em `/home` e em backups. Configurações que precisam sobreviver a uma reinstalação devem ser versionadas explicitamente no repositório, em vez de depender do estado acumulado da instalação anterior.

## Origem

Este projeto reorganiza a seleção de aplicativos e ajustes do repositório `rafatosta/fedora_gnome`, mantendo o Fedora no modelo tradicional e mutável.
