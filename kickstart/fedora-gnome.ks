# Fedora GNOME enxuto e mutável
# Destinado a mídia netinstall/boot do Fedora.
# O armazenamento fica deliberadamente interativo para evitar apagar /home por engano.

text
lang pt_BR.UTF-8
keyboard --vckeymap=br-abnt2 --xlayouts='br'
timezone America/Bahia --utc
network --bootproto=dhcp --device=link --activate
rootpw --lock
firstboot --enable
selinux --enforcing
firewall --enabled
services --enabled="NetworkManager,gdm,firewalld,bluetooth"

# Fonte de instalação: a mídia ou repositório configurado pela ISO usada como base.
# Não usar clearpart/autopart aqui: o particionamento deve ser confirmado no Anaconda.

%packages --excludedocs
@core
@standard

# Pilha gráfica / GNOME essencial
gdm
gnome-shell
gnome-session
gnome-control-center
gnome-settings-daemon
gnome-keyring
nautilus
xdg-desktop-portal
xdg-desktop-portal-gnome
xdg-user-dirs
xdg-user-dirs-gtk
polkit

# Áudio, vídeo, rede e energia
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

# Sessão e integração desktop
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

# Ferramentas usadas no ambiente atual
nodejs
python3-pip
adw-gtk3-theme
gnome-shell-extension-user-theme
gnome-shell-extension-appindicator

# Evita instalar itens explicitamente indesejados caso venham por grupos/dependências fracas
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

%post --erroronfail --log=/root/fedora-gnome-minimal.log
# Mantém o boot sem espera artificial por rede.
systemctl disable NetworkManager-wait-online.service || true

# GDM é o display manager do ambiente.
systemctl set-default graphical.target
systemctl enable gdm.service || true

# Diretório reservado para scripts/configurações locais do projeto.
install -d -m 0755 /usr/local/share/fedora-gnome-minimal
%end
