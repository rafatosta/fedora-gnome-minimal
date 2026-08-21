# NVIDIA e Secure Boot

Este projeto usa o mesmo modelo geral empregado no Fedora Workstation com os drivers NVIDIA empacotados para Fedora, mas sem depender da interface do GNOME Software.

## Fluxo habitual no Fedora Workstation

No uso manual pelo GNOME Software, o processo normalmente é percebido assim:

1. instalar o Fedora Workstation;
2. aplicar todas as atualizações;
3. manter/ativar o Secure Boot no firmware;
4. habilitar os repositórios de terceiros necessários;
5. instalar o driver NVIDIA pela GNOME Software;
6. definir uma senha temporária quando o sistema solicita o registro da chave;
7. reiniciar;
8. confirmar a chave no MokManager usando a senha criada;
9. inicializar novamente com o módulo NVIDIA autorizado pelo Secure Boot.

A GNOME Software esconde boa parte dos comandos envolvidos. O resultado final, porém, depende da mesma ideia: o módulo externo precisa ser construído, assinado e sua chave precisa ser confiável para o Secure Boot.

## Fluxo usado pelo Fedora GNOME Minimal

Neste projeto a etapa gráfica é substituída por `scripts/setup-nvidia.sh`.

O fluxo fica explícito:

1. o `post-install.sh` primeiro atualiza o Fedora;
2. configura os repositórios comuns;
3. chama `setup-nvidia.sh`;
4. o script habilita RPM Fusion Free e Nonfree;
5. instala `akmods`, `mokutil`, `openssl`, `kernel-devel` e `kernel-headers`;
6. garante que a chave local do `akmods` exista **antes** da primeira compilação do módulo NVIDIA;
7. instala `akmod-nvidia` e os componentes NVIDIA necessários;
8. força a compilação/recompilação do módulo com `akmods`;
9. se o Secure Boot estiver ativo e a chave ainda não estiver inscrita, executa `mokutil --import`;
10. o usuário define uma senha temporária no terminal;
11. no reboot seguinte, o MokManager solicita a confirmação da chave;
12. após a confirmação, o sistema inicializa normalmente com o driver NVIDIA.

Portanto, a diferença principal é a interface:

```text
Fedora Workstation
GNOME Software
      ↓
instalação do driver + preparação da chave
      ↓
reboot → MokManager → senha

Fedora GNOME Minimal
post-install.sh / setup-nvidia.sh
      ↓
instalação do driver + preparação da chave
      ↓
reboot → MokManager → senha
```

O passo no MokManager continua existindo porque a inscrição da chave é uma operação de confiança ligada ao Secure Boot e exige confirmação do usuário fora do sistema operacional.

## Ordem recomendada após uma instalação limpa

Para reproduzir o comportamento usado normalmente no Workstation:

```bash
sudo dnf upgrade --refresh -y
sudo reboot
```

Após retornar ao sistema, confirme que o Secure Boot está ativo:

```bash
mokutil --sb-state
```

Então execute a pós-instalação do projeto:

```bash
sudo bash ./scripts/post-install.sh
```

Se o script solicitar a importação da chave, escolha a senha temporária e reinicie. No MokManager, confirme a inscrição da chave usando essa mesma senha.

Depois do novo boot:

```bash
bash ./scripts/verify.sh
```

Também é possível conferir diretamente:

```bash
nvidia-smi
mokutil --sb-state
modinfo -F signer nvidia
```

## Atualizações futuras do kernel

A inscrição MOK é feita uma vez para a chave local usada pelo `akmods`. Depois disso, quando uma atualização instala um kernel novo ou atualiza o driver NVIDIA, o `akmods` recompila o módulo correspondente e o assina usando a mesma chave.

Em condições normais, não é necessário criar uma nova senha nem repetir a inscrição no MokManager a cada atualização de kernel.

## Observação sobre o Secure Boot

O projeto não ativa nem desativa Secure Boot no firmware. Essa configuração permanece sob controle do usuário/UEFI. O script apenas detecta seu estado e prepara o driver NVIDIA de forma compatível com ele.

Se o Secure Boot estiver desligado, o driver ainda pode ser instalado e o projeto continua gerando a chave para manter o processo reproduzível. Se ele for ativado posteriormente, a chave precisará estar inscrita para que o módulo NVIDIA seja carregado.
