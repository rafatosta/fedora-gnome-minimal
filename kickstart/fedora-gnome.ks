# Fedora GNOME Minimal - instalação baseada em pacotes
#
# Este Kickstart é executado pelo Anaconda durante a instalação FINAL.
# Ele define a seleção de software e o bootloader, mas deliberadamente NÃO
# define particionamento (clearpart/autopart/part). O armazenamento permanece
# interativo na WebUI do Anaconda, incluindo Reinstall Fedora quando disponível.
#
# A mídia é derivada da Fedora Everything netinstall com mkksiso. O modo de
# instalação é package-based, requisito do Anaconda para selecionar systemd-boot
# no momento da instalação por meio de inst.sdboot / bootloader --sdboot.

lang pt_BR.UTF-8
keyboard --vckeymap=br-abnt2 --xlayouts='br'
timezone America/Bahia --utc
network --bootproto=dhcp --device=link --activate
rootpw --lock
selinux --enforcing
firewall --enabled

# systemd-boot é a escolha deliberada do projeto para instalações UEFI.
bootloader --sdboot

%packages --excludedocs
@core
@standard

# Kernel e boot
kernel
kernel-modules
kernel-modules-extra
systemd-boot

# Identidade Workstation e primeira configuração
glibc-all-langpacks
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
-simple-scan
-mediawriter
-malcontent-control
-gnome-connections
-qemu-guest-agent
-virtualbox-guest-additions
-podman
-podman-sequoia
%end

%post --erroronfail --log=/root/fedora-gnome-minimal-install.log
# GDM / GNOME no sistema final.
systemctl set-default graphical.target
systemctl enable gdm.service || true
systemctl disable NetworkManager-wait-online.service || true

install -d -m 0755 /usr/local/share/fedora-gnome-minimal
cat > /usr/local/share/fedora-gnome-minimal/installation-mode <<'EOF'
package-based
EOF
%end
