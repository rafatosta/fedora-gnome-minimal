# Geração da mídia

O projeto usa `mkksiso`, do Lorax, para inserir o Kickstart em uma ISO oficial Fedora boot/netinstall. Isso evita recriar uma distribuição completa e mantém a origem dos pacotes nos repositórios oficiais.

## Dependência

```bash
sudo dnf install lorax
```

## Gerar

```bash
sudo bash ./build/build-iso.sh ~/Downloads/Fedora-*.iso
```

A saída será:

```text
dist/fedora-gnome-minimal.iso
```

## Segurança do armazenamento

O Kickstart não contém `clearpart` nem `autopart`. Isso é intencional: preservar `/home` exige que o disco seja particionado/revisado conscientemente no Anaconda. Uma reinstalação automatizada que apague o disco inteiro derrotaria o objetivo de manter os dados pessoais.

Se futuramente houver uma estratégia fixa de particionamento (por exemplo, `/home` em partição Btrfs separada), ela pode ser adicionada em um perfil Kickstart separado e explicitamente destrutivo.
