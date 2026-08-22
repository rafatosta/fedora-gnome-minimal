# Geração da mídia de instalação

A mídia do Fedora GNOME Minimal é composta com **Pungi + Lorax**, seguindo o fluxo package-based tradicional do Fedora.

## Dependências

```bash
sudo dnf install pungi lorax createrepo_c genisoimage isomd5sum
```

## Gerar

```bash
sudo bash ./build/build-iso.sh
```

A saída final será:

```text
dist/fedora-gnome-minimal.iso
dist/fedora-gnome-minimal.iso.sha256
```

O log principal fica em `dist/pungi.log`; os logs detalhados de cada fase ficam dentro de `dist/pungi/`.

## Fluxo

O Pungi usa `compose/fedora-gnome-minimal.conf` e executa:

1. `pkgset` a partir dos repositórios oficiais Fedora;
2. `gather` para resolver o conjunto definido em `comps.xml`;
3. `createrepo` para produzir o repositório da variante;
4. `buildinstall` com Lorax para criar o runtime/boot do Anaconda;
5. `createiso` para gerar a ISO completa.

A mídia final contém os RPMs e não é uma Live image nem uma netinstall modificada com `mkksiso`.

## Instalação

`kickstart/fedora-gnome.ks` é incorporado pelo `buildinstall`. Ele:

- seleciona o ambiente `Fedora GNOME Minimal`;
- usa `bootloader --sdboot`;
- mantém `root` bloqueado;
- não cria usuário;
- não automatiza particionamento;
- habilita GDM/`graphical.target` para que o GNOME Initial Setup crie o primeiro usuário no primeiro boot.
