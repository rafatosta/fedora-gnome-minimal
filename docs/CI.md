# CI e build da ISO

O projeto usa GitHub Actions para separar validação rápida da geração da mídia.

## `Validate`

Executa automaticamente em pull requests e em pushes para `main`.

Verifica:

- sintaxe dos scripts Bash com `bash -n`;
- scripts com ShellCheck;
- `kickstart/fedora-gnome.ks` com `ksvalidator` do Fedora 44;
- entradas duplicadas nos manifests RPM e Flatpak.

Esse workflow não constrói a ISO.

## `Build ISO`

Executa em dois cenários:

- manualmente, em **Actions → Build ISO → Run workflow**;
- automaticamente quando uma tag `v*` é enviada ao repositório.

A execução manual possui os parâmetros:

- `fedora_release`: versão Fedora usada pelo container e pela ISO fonte;
- `compose`: identificador do compose oficial;
- `iso_url`: permite substituir explicitamente a URL oficial da Fedora Everything netinstall;
- `iso_sha256`: checksum esperado da ISO fonte;
- `install_repo_url`: permite substituir a árvore Fedora Everything usada para baixar os pacotes durante a instalação;
- `publish_release`: publica o resultado como prerelease quando habilitado.

Para Fedora 44 compose 1.7, o workflow conhece o checksum oficial x86_64. Para qualquer outra versão/compose, o checksum deve ser informado explicitamente.

## Fonte do Fedora

Por padrão a ISO fonte é:

```text
https://download.fedoraproject.org/pub/fedora/linux/releases/<versão>/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-<versão>-<compose>.iso
```

O download é sempre verificado com SHA-256 antes da geração da mídia.

A árvore de pacotes usada pelo Anaconda durante a instalação é, por padrão:

```text
https://download.fedoraproject.org/pub/fedora/linux/releases/<versão>/Everything/x86_64/os/
```

## Como o build roda

O job usa `ubuntu-24.04`, mas executa `mkksiso` dentro de um container Fedora da mesma versão alvo.

Dentro do container é instalado apenas o conjunto necessário do Lorax. Não há mais VM temporária, KVM, libvirt, OVMF ou `livemedia-creator`.

O container continua privilegiado porque versões atuais do `mkksiso` precisam de privilégios para atualizar corretamente a imagem EFI embutida e produzir uma ISO totalmente bootável também quando gravada em USB.

A receita usada pela CI é a mesma do build local:

```text
build/build-iso.sh
```

## Arquitetura da mídia

A ISO final preserva o runtime e a estrutura de boot da Fedora Everything netinstall. `mkksiso` incorpora o Kickstart do projeto e adiciona:

```text
inst.sdboot
inst.profile=fedora-workstation
inst.pauseatsummary
inst.repo=<árvore Fedora Everything>
```

A instalação é package-based. O Kickstart define os pacotes e `bootloader --sdboot`, mas não define armazenamento. O usuário continua escolhendo o disco e o layout pela WebUI.

## Rede

Essa mídia é netinstall. O sistema alvo precisa ter acesso ao repositório Fedora durante a instalação.

O primeiro ciclo de testes deve ser feito com conectividade de rede confiável. Em hardware com Wi-Fi, valide explicitamente a configuração da rede no ambiente do instalador antes de considerar a mídia pronta para uso real.

## Espaço em disco e tempo

Como não existe mais disco virtual temporário nem squashfs Live, o build é consideravelmente mais leve. O maior arquivo mantido simultaneamente é a ISO fonte junto da ISO modificada.

O timeout do workflow foi reduzido em relação ao antigo pipeline Live.

## Resultados

### Execução manual — padrão

Com `publish_release=true`, o workflow cria uma prerelease:

```text
build-<número da execução>
```

contendo:

```text
fedora-gnome-minimal.iso
fedora-gnome-minimal.iso.sha256
```

### Execução manual — artifact temporário

Com `publish_release=false`, a ISO é enviada como artifact por 1 dia.

### Tags

Uma tag como:

```bash
git tag v44.1
git push origin v44.1
```

dispara o build e publica/atualiza a Release `v44.1` com a ISO e o SHA-256.

## Ciclo de testes

1. faça merge das alterações em `main`;
2. confirme que `Validate` passou;
3. execute manualmente `Build ISO` mantendo Fedora 44 / compose 1.7;
4. baixe a ISO da prerelease gerada;
5. teste boot UEFI em VM;
6. confirme que a WebUI usa o perfil Workstation e permite configurar o armazenamento;
7. instale em um disco virtual vazio;
8. remova a ISO e confirme que o sistema instalado inicia com `systemd-boot` (`bootctl status`);
9. faça uma segunda instalação na mesma VM para testar `Reinstall Fedora` e preservação de `/home`;
10. somente depois avance para hardware real e NVIDIA/MOK.

## Nova versão do Fedora

Antes de construir uma nova versão major:

1. valide novamente `systemd-boot` + Anaconda WebUI conforme `docs/VALIDATION.md`;
2. obtenha compose e SHA-256 oficiais da Fedora Everything x86_64;
3. valide a URL da árvore `Everything/x86_64/os/`;
4. informe os novos valores no workflow manual;
5. só depois atualize os defaults no repositório.
