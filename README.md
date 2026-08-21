# Fedora GNOME Minimal

Projeto pessoal para instalar um Fedora GNOME tradicional, mutável e reproduzível, com apenas os componentes necessários ao uso diário.

A proposta é substituir o modelo "instalar Fedora Workstation completo e depois remover coisas" por uma instalação enxuta definida em código:

- Fedora tradicional, administrado com `dnf`;
- GNOME funcional, sem depender do conjunto completo do Workstation;
- pacotes RPM essenciais definidos em arquivo;
- aplicativos Flatpak definidos em arquivo;
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
sudo ./build/build-iso.sh /caminho/Fedora-netinst.iso
```

4. Grave `dist/fedora-gnome-minimal.iso` em um pendrive.
5. Durante a instalação, revise o particionamento antes de confirmar. O Kickstart deste projeto não executa `clearpart` automaticamente.
6. Depois do primeiro boot:

```bash
sudo ./scripts/post-install.sh
```

## Princípio do projeto

O sistema operacional é descartável e reproduzível. Dados pessoais devem permanecer em `/home` e em backups. Configurações que precisam sobreviver a uma reinstalação devem ser versionadas explicitamente no repositório, em vez de depender do estado acumulado da instalação anterior.

## Origem

Este projeto reorganiza a seleção de aplicativos e ajustes do repositório `rafatosta/fedora_gnome`, mantendo o Fedora no modelo tradicional e mutável.
