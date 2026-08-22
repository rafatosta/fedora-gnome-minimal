# Geração da mídia Live

A mídia do Fedora GNOME Minimal é construída com `livemedia-creator`, do Lorax. O objetivo é gerar uma **imagem Live própria** contendo GNOME + Anaconda WebUI, preservando a experiência de instalação moderna do Fedora Workstation.

A imagem é construída em **UEFI** e usa `systemd-boot` em vez de GRUB como bootloader alvo.

## Por que Live ISO

A WebUI moderna do Fedora Workstation está associada ao fluxo de instalação Live. O Kickstart deste projeto é usado como **receita de composição da imagem**, não como automação da instalação no computador final.

Consequência: ao inicializar a mídia, o usuário continua escolhendo o destino e o cenário de armazenamento pela interface do Anaconda.

## Dependências

```bash
sudo dnf install lorax lorax-lmc-virt
```

O `lorax-lmc-virt` fornece a infraestrutura QEMU/UEFI usada por `livemedia-creator --virt-uefi`. O build verifica a presença do firmware EDK2 em `/usr/share/edk2`.

## ISO fonte

Use uma ISO Fedora Everything/netinstall compatível com a versão que está sendo construída. Ela fornece o ambiente de instalação usado pelo `livemedia-creator` durante a composição.

## Gerar

```bash
sudo bash ./build/build-iso.sh ~/Downloads/Fedora-Everything-netinst-x86_64.iso
```

Internamente, o build usa:

```text
livemedia-creator --make-iso --virt-uefi ...
```

`--virt-uefi` é obrigatório porque o projeto usa `systemd-boot`, que funciona apenas em UEFI.

A saída final será copiada para:

```text
dist/fedora-gnome-minimal.iso
```

Os artefatos e logs intermediários ficam em:

```text
dist/lmc/
```

## Partições usadas durante o build

O Kickstart cria no disco temporário da composição:

- ESP de 1 GiB em `/boot/efi`;
- raiz ext4 temporária para construir a Live image.

Isso serve apenas para permitir que a imagem seja construída de forma coerente com `systemd-boot`.

## Segurança do armazenamento

Há dois particionamentos diferentes neste fluxo e eles não devem ser confundidos.

### Durante a construção da ISO

`kickstart/fedora-gnome.ks` contém `clearpart` e diretivas `part`. Elas atuam no **disco virtual temporário da composição** criado pelo `livemedia-creator`. Esse disco é descartável e existe apenas para construir o filesystem da mídia Live.

### Durante a instalação no computador

O Kickstart de composição não automatiza o armazenamento do computador final. A WebUI do Anaconda apresenta os cenários disponíveis, como:

- usar o disco inteiro;
- usar espaço livre;
- atribuir pontos de montagem;
- `Reinstall Fedora`, quando a instalação existente satisfaz os critérios do Anaconda.

Portanto, nenhuma regra do repositório apaga automaticamente a `/home` do computador durante a instalação final.

## systemd-boot

O Kickstart contém `bootloader --sdboot` e instala o pacote Fedora `systemd-boot`, que é a variante indicada para Secure Boot.

O suporte existe no Anaconda, mas não é o padrão Fedora e ainda é descrito upstream como alternativa para testes/desenvolvimento. Consulte `docs/SYSTEMD-BOOT.md` antes de migrar o projeto para uma nova versão major do Fedora.

## Recuperação

Quando `Reinstall Fedora` estiver disponível, esse é o fluxo preferencial para reconstruir o sistema preservando os dados pessoais. Se o Anaconda não oferecer essa opção devido ao layout existente, use a atribuição manual de pontos de montagem e confirme cuidadosamente quais volumes serão formatados.
