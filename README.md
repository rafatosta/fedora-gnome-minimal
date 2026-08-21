# Fedora GNOME Minimal

Projeto pessoal para instalar um Fedora GNOME tradicional, mutável e reproduzível, com apenas os componentes necessários ao uso diário.

A proposta é substituir o modelo "instalar Fedora Workstation completo e depois remover coisas" por uma instalação enxuta definida em código:

- Fedora tradicional, administrado com `dnf`;
- GNOME funcional, sem depender do conjunto completo do Workstation;
- pacotes RPM essenciais definidos em arquivo;
- aplicativos Flatpak definidos em arquivo;
- NVIDIA via RPM Fusion com suporte a Secure Boot e assinatura automática por `akmods`;
- serviços não utilizados desabilitados de forma defensiva;
- mídia instalável gerada a partir de uma ISO oficial Fedora netinstall/boot com `mkksiso`;
- `/home` tratado como dado persistente, não como parte do sistema reproduzível.

## Estrutura

```text
kickstart/
  fedora-gnome.ks        seleção base e instalação do Fedora
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
  build-iso.sh           injeta o Kickstart em uma ISO Fedora
  README.md              instruções de geração da mídia
```

## Fluxo recomendado

1. Baixe uma ISO oficial Fedora Everything/Server netinstall compatível com a versão alvo.
2. Instale `lorax` no sistema usado para gerar a mídia.
3. Execute:

```bash
sudo bash ./build/build-iso.sh /caminho/Fedora-netinst.iso
```

4. Grave `dist/fedora-gnome-minimal.iso` em um pendrive.
5. Durante a instalação, revise o particionamento antes de confirmar. O Kickstart deste projeto não executa `clearpart` automaticamente.
6. Depois do primeiro boot:

```bash
sudo bash ./scripts/post-install.sh
```

## NVIDIA e Secure Boot

O script `scripts/setup-nvidia.sh` configura os repositórios RPM Fusion Free e Nonfree e prepara o Fedora para usar o driver NVIDIA proprietário com Secure Boot.

A ordem é intencional:

1. instala `akmods`, `mokutil`, `openssl`, `kernel-devel` e `kernel-headers`;
2. gera a chave local do `akmods` antes da primeira compilação do driver;
3. instala `akmod-nvidia` e `xorg-x11-drv-nvidia-cuda`;
4. força a reconstrução dos módulos já assinados;
5. quando Secure Boot está ativo, solicita a importação da chave pública no MOK caso ela ainda não esteja inscrita.

Na primeira instalação com Secure Boot ativo, `mokutil` solicita uma senha temporária. No reboot seguinte, o firmware abre o MokManager; confirme a inscrição da chave usando essa senha. Esse passo é necessariamente interativo e não pode ser automatizado pela imagem.

Depois que a chave é inscrita, atualizações futuras de kernel ou do driver são tratadas pelo `akmods`, que recompila e assina os módulos NVIDIA automaticamente com a mesma chave.

Para conferir o estado:

```bash
bash ./scripts/verify.sh
```

A verificação mostra o estado do Secure Boot, a GPU/versão do driver, o assinante do módulo NVIDIA e se a chave do `akmods` está inscrita.

## Princípio do projeto

O sistema operacional é descartável e reproduzível. Dados pessoais devem permanecer em `/home` e em backups. Configurações que precisam sobreviver a uma reinstalação devem ser versionadas explicitamente no repositório, em vez de depender do estado acumulado da instalação anterior.

## Origem

Este projeto reorganiza a seleção de aplicativos e ajustes do repositório `rafatosta/fedora_gnome`, mantendo o Fedora no modelo tradicional e mutável.
