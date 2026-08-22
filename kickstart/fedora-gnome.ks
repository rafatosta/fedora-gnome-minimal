# Fedora GNOME Minimal - definição da IMAGEM LIVE
#
# IMPORTANTE: este Kickstart é usado pelo livemedia-creator para construir
# a mídia Live. As diretivas de particionamento abaixo atuam somente no disco
# temporário da construção da imagem; NÃO definem o particionamento do PC do
# usuário. A instalação final permanece interativa pela WebUI do Anaconda.
#
# O projeto usa systemd-boot deliberadamente. Para Live installs o Anaconda
# exige que a própria imagem tenha sido construída com systemd-boot.
#
# Não definir graphical/text/cmdline neste Kickstart: o livemedia-creator
# rejeita display modes explícitos porque eles interferem no fluxo de composição.

lang pt_BR.UTF-8
keyboard --vckeymap=br-abnt2 --xlayouts='br'
timezone America/Bahia --utc
network --bootproto=dhcp --device=link --activate
rootpw --lock
selinux --enforcing
firewall --enabled
shutdown

# systemd-boot: UEFI only. A construção é executada com --virt-uefi.
bootloader --sdboot

# Disco temporário usado durante a composição da imagem Live.
zerombr
clearpart --all --initlabel --disklabel=gpt
part /boot/efi --fstype="efi" --size=1024 --fsoptions="umask=0077,shortname=winnt"
part / --fstype="ext4" --size=12288

%packages --excludedocs
@core
@standard

# Kernel e infraestrutura necessária para mídia Live
kernel
kernel-modules
kernel-modules-extra
dracut-live
livesys-scripts
glibc-all-langpacks

# systemd-boot assinado para Secure Boot (não usar systemd-boot-unsigned)
systemd-boot

# Dependências usadas pelo Lorax para empacotar a ISO bootável.
#
# O template x86 do Lorax ainda produz estruturas El Torito/GRUB para a própria
# mídia ISO e precisa dos módulos i386-pc, além dos binários EFI usados para
# montar a árvore EFI/BOOT. Esses pacotes NÃO selecionam GRUB como bootloader do
# sistema instalado: a diretiva acima continua sendo `bootloader --sdboot`.
grub2-pc-modules
grub2-efi-x64
grub2-efi-x64-cdboot
shim-x64

# Instalador Fedora / WebUI usada pelo Workstation
anaconda
anaconda-install-env-deps
anaconda-live
anaconda-webui
fedora-release-workstation
fedora-logos
gnome-initial-setup

# GNOME essencial
gdm
gnome-shell
gnome-session
gnome-control-center
gnome-settings-daemon
gnome-keyring
nautilus
gnome-software
xdg-desktop-portal
xdg-desktop-portal-gnome
xdg-user-dirs
xdg-user-dirs-gtk
polkit

# Áudio, vídeo, rede, Bluetooth e energia
NetworkManager
NetworkManager-wifi
bluez
bluez-tools
pipewire
pipewire-alsa
pipewire-pulseaudio
wireplumber
upower
udisks2
firewalld

# Integração desktop
flatpak
fwupd
gvfs
gvfs-afc
gvfs-goa
gvfs-gphoto2
gvfs-mtp
gvfs-smb
xdg-utils
bash-completion

# Sistema e diagnóstico
dnf5
sudo
curl
wget
git
rsync
pciutils
usbutils
lsof
htop

# Ferramentas usadas no ambiente pessoal
nodejs
python3-pip
adw-gtk3-theme
gnome-shell-extension-user-theme
gnome-shell-extension-appindicator

# Evita aplicativos não utilizados.
#
# Não excluir firefox aqui: anaconda-webui exige Firefox quando a imagem usa
# fedora-release-workstation. A remoção deve ser reavaliada somente depois de
# validar a composição e o fluxo de instalação da mídia Live.
#
# Não excluir abrt isoladamente: @standard inclui abrt-cli, que depende de abrt.
# Para remover ABRT no futuro é necessário excluir o conjunto de dependências de
# forma coerente, sem quebrar a resolução de pacotes do Anaconda.
-gnome-tour
-gnome-boxes
-gnome-maps
-gnome-weather
-showtime
-decibels
-simple-scan
-mediawriter
-malcontent-control
-gnome-connections
-qemu-guest-agent
-virtualbox-guest-additions
-podman
-podman-sequoia
%end

%post --erroronfail --log=/root/fedora-gnome-minimal-live.log
# Serviços da sessão Live.
systemctl enable livesys.service || true
systemctl enable livesys-late.service || true
systemctl enable tmp.mount || true

# GDM / GNOME.
systemctl set-default graphical.target
systemctl enable gdm.service || true
systemctl disable NetworkManager-wait-online.service || true

# Identifica a sessão Live como GNOME.
if [[ -f /etc/sysconfig/livesys ]]; then
  sed -i 's/^livesys_session=.*/livesys_session="gnome"/' /etc/sysconfig/livesys
fi

# Compatibilidade systemd-boot <-> Lorax.
#
# Com bootloader --sdboot o Anaconda mantém o kernel no layout usado pelo
# systemd-boot/UKI e não regenera um initramfs tradicional em /boot. A etapa
# posterior do livemedia-creator, porém, ainda usa pylorax.findkernels(), que
# procura especificamente /boot/vmlinuz-<versão> para reconstruir o initramfs
# da própria mídia Live. Sem esta ponte a instalação no QEMU termina com sucesso,
# mas a composição aborta com "No kernels found, cannot rebuild_initrds".
#
# Copiamos apenas o vmlinuz já instalado para o nome convencional esperado pelo
# Lorax. Isso não troca o bootloader nem cria configuração GRUB: o sistema segue
# usando systemd-boot e a cópia serve como entrada para a geração da mídia Live.
lorax_kernel_count=0
for kernel_dir in /usr/lib/modules/*; do
  [[ -d "$kernel_dir" ]] || continue
  kernel_version="${kernel_dir##*/}"
  kernel_source="$kernel_dir/vmlinuz"

  if [[ -f "$kernel_source" ]]; then
    install -m 0644 "$kernel_source" "/boot/vmlinuz-$kernel_version"
    echo "Lorax kernel bridge: /boot/vmlinuz-$kernel_version"
    lorax_kernel_count=$((lorax_kernel_count + 1))
  fi
done

if [[ "$lorax_kernel_count" -eq 0 ]]; then
  echo "ERRO: nenhum kernel encontrado em /usr/lib/modules/*/vmlinuz para compatibilidade com o Lorax." >&2
  exit 1
fi

# O Lorax monta apenas a partição raiz depois que o Anaconda termina. Como
# /boot/efi é uma ESP separada, os arquivos EFI instalados nela ficam invisíveis
# para o teste exists("boot/efi/EFI/*/gcdx64.efi") do template x86.tmpl. Sem esse
# teste o efi.tmpl não é executado e o empacotamento falha porque EFI/BOOT e
# images/efiboot.img nunca são criados.
#
# Para a etapa de composição, desmontamos temporariamente a ESP e colocamos no
# diretório subjacente da partição raiz cópias dos binários de mídia fornecidos
# pelos próprios pacotes Fedora. Em seguida a ESP é remontada. Assim o sistema
# instalado continua usando systemd-boot na ESP real, enquanto o Lorax consegue
# enxergar os arquivos necessários ao montar somente a raiz.
if mountpoint -q /boot/efi; then
  umount /boot/efi
  lorax_efi_dir=/boot/efi/EFI/fedora
  install -d -m 0755 "$lorax_efi_dir"

  grub_cdboot="$(find /usr/lib/efi/grub2 -type f -path '*/EFI/fedora/gcdx64.efi' -print -quit 2>/dev/null || true)"
  shim_bin="$(find /usr/lib/efi/shim -type f -path '*/EFI/fedora/shimx64.efi' -print -quit 2>/dev/null || true)"
  mm_bin="$(find /usr/lib/efi/shim -type f -path '*/EFI/fedora/mmx64.efi' -print -quit 2>/dev/null || true)"

  if [[ -z "$grub_cdboot" || -z "$shim_bin" || -z "$mm_bin" ]]; then
    echo "ERRO: binários EFI de mídia não encontrados em /usr/lib/efi/{grub2,shim}." >&2
    exit 1
  fi

  install -m 0644 "$grub_cdboot" "$lorax_efi_dir/gcdx64.efi"
  install -m 0644 "$shim_bin" "$lorax_efi_dir/shimx64.efi"
  install -m 0644 "$mm_bin" "$lorax_efi_dir/mmx64.efi"
  echo "Lorax EFI bridge: arquivos de mídia preparados na raiz subjacente."

  mount /boot/efi
else
  echo "ERRO: /boot/efi não está montado durante o %post; não é possível preparar a ponte EFI do Lorax." >&2
  exit 1
fi

# A imagem Live não pode carregar o /etc/fstab criado pelo Anaconda para o
# disco temporário usado durante a composição. Os UUIDs desse disco não existem
# quando a ISO inicia e o systemd entra em emergency.target tentando montar a
# antiga raiz/ESP. O dracut-live monta o rootfs da mídia; portanto o fstab da
# imagem deve ficar vazio. O Anaconda criará um novo /etc/fstab no sistema final
# conforme o particionamento escolhido pelo usuário durante a instalação.
: > /etc/fstab

# O sistema instalado deve gerar sua própria identidade.
rm -f /etc/machine-id
: > /etc/machine-id
rm -f /var/lib/systemd/random-seed
rm -f /boot/*-rescue* || true

install -d -m 0755 /usr/local/share/fedora-gnome-minimal
%end
