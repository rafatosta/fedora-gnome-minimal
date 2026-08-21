# Decisões de projeto

## 1. Fedora mutável

O sistema continua sendo administrado por `dnf`. Não há rpm-ostree, bootc ou raiz baseada em imagem.

## 2. Base mínima prática, não mínima absoluta

A instalação inclui `@core` e `@standard`, mais os componentes necessários para uma sessão GNOME funcional. O objetivo é reduzir software supérfluo sem remover peças de integração que costumam causar falhas difíceis de diagnosticar.

## 3. Aplicativos pessoais separados da base

Google Chrome, VS Code e os Flatpaks ficam fora do núcleo do Kickstart. Isso torna a instalação base mais resistente a indisponibilidade temporária de repositórios de terceiros.

## 4. Dados fora da imagem mental do sistema

`/home` deve ser preservado/backup. Caches e configurações descartáveis não fazem parte da garantia de reprodutibilidade.

## 5. Serviços

A lista de serviços desabilitados foi herdada do perfil anterior, mas o script agora verifica a existência da unit antes de agir. Serviços fundamentais de rede, energia, armazenamento e GPU não são desabilitados.
