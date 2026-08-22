# CI e build da ISO

O projeto usa GitHub Actions para separar validação rápida de composição pesada da imagem.

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
- `iso_url`: permite substituir explicitamente a URL oficial;
- `iso_sha256`: checksum esperado da ISO fonte;
- `publish_release`: publica o resultado como prerelease quando habilitado.

Para Fedora 44 compose 1.7, o workflow conhece o checksum oficial x86_64. Para qualquer outra versão/compose, o checksum deve ser informado explicitamente. O build falha de propósito se não houver um checksum conhecido.

## Fonte do Fedora

Por padrão a URL é construída no formato oficial:

```text
https://download.fedoraproject.org/pub/fedora/linux/releases/<versão>/Everything/x86_64/iso/Fedora-Everything-netinst-x86_64-<versão>-<compose>.iso
```

O download é sempre verificado com SHA-256 antes da composição.

## Como o build roda

O job usa um runner hospedado `ubuntu-24.04`, mas executa as ferramentas de composição dentro de um container da mesma versão do Fedora alvo.

Dentro do container são instalados:

- `lorax`;
- `lorax-lmc-virt`;
- `edk2-ovmf`;
- libvirt/QEMU.

A composição continua chamando `build/build-iso.sh`, portanto a CI usa a mesma receita do build Fedora local.

### KVM

O workflow verifica se `/dev/kvm` está disponível no runner.

- com `/dev/kvm`, QEMU pode usar aceleração de hardware;
- sem `/dev/kvm`, libvirt/QEMU pode usar emulação por software, que é consideravelmente mais lenta.

O runner é iniciado com container privilegiado porque o `livemedia-creator --virt-uefi` precisa criar uma VM UEFI durante a composição.

A disponibilidade de virtualização aninhada em runners hospedados pelo GitHub não deve ser tratada como garantia de plataforma. Por isso os logs do `livemedia-creator`/libvirt são preservados para diagnóstico. Se o build hospedado se mostrar instável de forma recorrente, o job pode ser migrado para um runner Fedora `self-hosted` sem mudar a receita da ISO.

## Espaço em disco

A composição precisa manter simultaneamente a ISO Fedora fonte, o disco virtual temporário e a ISO resultante. Antes do build o workflow remove toolchains grandes pré-instaladas no runner que não são necessárias ao projeto.

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

Isso evita consumir a cota de armazenamento de artifacts com uma ISO grande.

### Execução manual — artifact temporário

Com `publish_release=false`, a ISO é enviada como artifact por apenas 1 dia. Use essa opção somente quando o tamanho da imagem couber na cota disponível do GitHub Actions.

### Tags

Uma tag como:

```bash
git tag v44.1
git push origin v44.1
```

dispara a composição e publica/atualiza a Release `v44.1` com a ISO e o SHA-256.

## Primeiro ciclo de testes

1. faça merge das alterações em `main`;
2. confirme que `Validate` passou;
3. execute manualmente `Build ISO` mantendo Fedora 44 / compose 1.7;
4. baixe a ISO da prerelease gerada;
5. teste boot e instalação em VM UEFI;
6. teste `Reinstall Fedora` e preservação da `/home` em uma segunda instalação na mesma VM;
7. somente depois avance para hardware real e NVIDIA/MOK.

## Nova versão do Fedora

Antes de construir uma nova versão major:

1. valide novamente `systemd-boot` + Anaconda WebUI conforme `docs/VALIDATION.md`;
2. obtenha o compose e o SHA-256 oficiais da nova Fedora Everything x86_64;
3. informe esses valores no workflow manual;
4. só depois atualize os defaults do workflow no repositório.
