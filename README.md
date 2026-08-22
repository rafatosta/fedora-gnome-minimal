# Fedora GNOME Minimal

Projeto pessoal para instalar um Fedora GNOME tradicional, mutável e reproduzível, com apenas os componentes necessários ao uso diário.

A proposta é substituir o modelo "instalar Fedora Workstation completo e depois remover coisas" por uma imagem Live enxuta, mantendo a experiência moderna de instalação do Fedora Workstation:

- Fedora tradicional, administrado com `dnf`;
- GNOME funcional, sem depender do conjunto completo do Workstation;
- imagem **Live** própria;
- **Anaconda WebUI**, como no Fedora Workstation atual;
- armazenamento decidido pelo usuário no instalador;
- possibilidade de `Reinstall Fedora` quando o layout existente é compatível, preservando `/home` e dados pessoais;
- `systemd-boot` em UEFI, em vez de GRUB, como escolha deliberada do projeto;
- Secure Boot suportado com o pacote Fedora assinado `systemd-boot`;
- pacotes RPM essenciais definidos em arquivo;
- aplicativos Flatpak definidos em arquivo;
- NVIDIA via RPM Fusion com suporte a Secure Boot e assinatura automática por `akmods`;
- serviços não utilizados desabilitados de forma defensiva.

## Estrutura

```text
kickstart/
  fedora-gnome.ks        receita usada para CONSTRUIR a imagem Live
packages/
  rpm.txt                aplicativos/pacotes RPM adicionais
  flatpak.txt            aplicativos Flatpak
scripts/
  setup-repositories.sh  repositórios de terceiros
  setup-nvidia.sh        RPM Fusion, NVIDIA, akmods e Secure Boot
  install-rpm-apps.sh    instalação dos RPMs adicionais
  install-flatpaks.sh    configuração do Flathub e Flatpaks
  disable-services.sh    serviços não utilizados
  post-install.sh        orquestrador pós-instalação
  verify.sh              checagem rápida do ambiente
build/
  build-iso.sh           gera a imagem Live com livemedia-creator em UEFI
  README.md              instruções de geração da mídia
docs/
  NVIDIA-SECURE-BOOT.md  fluxo detalhado do driver NVIDIA e MOK
  SYSTEMD-BOOT.md        arquitetura, Secure Boot e limitações do systemd-boot
  VALIDATION.md          premissas técnicas validadas para o projeto
```

## Instalação e recuperação

O Kickstart deste repositório **não é executado para particionar o computador do usuário**. Ele serve apenas como receita de composição da imagem Live.

Ao iniciar o pendrive, a instalação final acontece pela WebUI do Anaconda. Assim, as decisões de armazenamento permanecem interativas, incluindo os cenários oferecidos pelo instalador quando aplicáveis:

- usar o disco inteiro;
- usar espaço livre;
- atribuir pontos de montagem manualmente;
- **Reinstall Fedora**, quando uma instalação Fedora compatível é detectada.

A opção `Reinstall Fedora` é especialmente importante para este projeto: ela permite reconstruir o sistema mantendo a home e os dados pessoais quando o layout existente atende aos critérios do Anaconda.

> As diretivas `clearpart` e `part` existentes em `kickstart/fedora-gnome.ks` atuam exclusivamente no disco temporário criado durante a **construção da imagem Live** pelo `livemedia-creator`. Elas não são aplicadas ao disco do computador que receberá o Fedora.

## systemd-boot

O projeto usa `systemd-boot` no sistema instalado. Essa não é a configuração padrão do Fedora: o suporte existe no Anaconda, mas a documentação upstream ainda o trata como alternativa para testes/desenvolvimento.

Para Live installs, o Anaconda exige que a própria imagem Live tenha sido construída com `systemd-boot`; por isso:

- o Kickstart usa `bootloader --sdboot`;
- a composição roda com `livemedia-creator --virt-uefi`;
- o disco temporário de build possui uma ESP dedicada de 1 GiB;
- o pacote usado é `systemd-boot`, assinado para Secure Boot, e não `systemd-boot-unsigned`.

Documentação detalhada: [`docs/SYSTEMD-BOOT.md`](docs/SYSTEMD-BOOT.md).

## Gerar a mídia

1. Baixe uma ISO Fedora Everything/netinstall da mesma versão alvo.
2. Instale as ferramentas de composição:

```bash
sudo dnf install lorax lorax-lmc-virt
```

3. Gere a imagem:

```bash
sudo bash ./build/build-iso.sh /caminho/Fedora-Everything-netinst.iso
```

4. A saída será:

```text
dist/fedora-gnome-minimal.iso
```

5. Grave a ISO em um pendrive e inicialize normalmente em UEFI.

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

O fluxo é equivalente ao que acontece quando o driver é instalado pelo GNOME Software no Fedora Workstation, mas aqui as etapas são explícitas no terminal. O projeto não ativa nem desativa Secure Boot no firmware.

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
