# Fedora GNOME Minimal - definição da IMAGEM LIVE
#
# IMPORTANTE: este Kickstart é usado pelo livemedia-creator para construir
# a mídia Live. As diretivas de particionamento abaixo atuam somente no disco
# temporário da construção da imagem; NÃO definem o particionamento do PC do
# usuário. A instalação final permanece interativa pela WebUI do Anaconda.
#
# O projeto usa systemd-boot deliberadamente. Para Live installs o Anaconda
# exige que a própria imagem tenha sido construída com systemd-boot.

graphical
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

# Evita aplicativos não utilizados
-gnome-tour
-gnome-boxes
-gnome-maps
-gnome-weather
-showtime
-decibels
-firefox
-abrt
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

# O sistema instalado deve gerar sua própria identidade.
rm -f /etc/machine-id
: > /etc/machine-id
rm -f /var/lib/systemd/random-seed
rm -f /boot/*-rescue* || true

install -d -m 0755 /usr/local/share/fedora-gnome-minimal
%end
