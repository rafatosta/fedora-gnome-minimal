# CI e build da ISO

O projeto separa validação rápida da composição completa da mídia.

## Validate

Executa em pull requests e em pushes para `main`.

Verifica:

- Bash com `bash -n` e ShellCheck;
- Kickstart com `ksvalidator`;
- XML de `comps.xml` e `variants.xml`;
- sintaxe da configuração Pungi;
- ausência de particionamento automático e de criação de usuário no Kickstart;
- presença de `rootpw --lock`, `gnome-initial-setup`, GDM e `bootloader --sdboot`;
- duplicidades nos manifests RPM e Flatpak.

## Build ISO

Executa manualmente ou em tags `v*`.

O workflow usa um runner Ubuntu, mas executa a composição dentro de um container Fedora da versão alvo. O container instala:

```text
pungi
lorax
createrepo_c
genisoimage
isomd5sum
pykickstart
libcomps
```

O container é privilegiado porque Lorax/buildinstall precisa criar o runtime e as estruturas de boot da ISO.

## Fontes de pacotes

`compose/fedora-gnome-minimal.conf` usa `pkgset_source = "repos"`, suportado pelo Pungi, apontando para os repositórios oficiais Fedora 44 release e updates.

O Pungi resolve dependências, cria um repositório próprio para a variante e o inclui na ISO final.

## Artefatos

Em execução manual com `publish_release=true`, é criada a prerelease:

```text
build-<número>
```

com:

```text
fedora-gnome-minimal.iso
fedora-gnome-minimal.iso.sha256
```

Os logs do Pungi e das fases internas são enviados como artifact por 7 dias.

## Ciclo de validação da mídia

1. confirmar `Validate`;
2. executar `Build ISO`;
3. iniciar a ISO em VM UEFI;
4. confirmar que o Anaconda clássico abre normalmente;
5. confirmar que a seleção de software já corresponde ao ambiente Fedora GNOME Minimal;
6. testar instalação automática de software com armazenamento ainda interativo;
7. retirar a ISO e confirmar boot por systemd-boot;
8. confirmar que o primeiro boot gráfico abre o GNOME Initial Setup e permite criar o primeiro usuário;
9. validar `bootctl status`;
10. repetir instalação preservando `/home` sem formatação;
11. somente então testar hardware real, Secure Boot e NVIDIA/MOK.

## Nova versão do Fedora

Cada nova versão major exige revisão de:

- URLs dos repositórios em `compose/fedora-gnome-minimal.conf`;
- disponibilidade dos pacotes do `comps.xml`;
- comportamento do Anaconda com `bootloader --sdboot`;
- comportamento do GNOME Initial Setup sem usuários pré-criados;
- compose Pungi/Lorax em x86_64.
