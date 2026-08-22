# Fedora GNOME Minimal - instalação package-based
#
# Este Kickstart é incorporado pelo buildinstall/Lorax da composição Pungi e
# executado pelo Anaconda na instalação FINAL. Ele define software e bootloader,
# mas NÃO define clearpart/autopart/part: o armazenamento continua interativo.
#
# Política de usuário: nenhuma conta comum é criada no instalador. A conta root
# permanece bloqueada e o primeiro usuário é criado pelo GNOME Initial Setup no
# primeiro boot gráfico, seguindo o modelo do Fedora Workstation.

lang pt_BR.UTF-8
keyboard --vckeymap=br-abnt2 --xlayouts='br'
timezone America/Bahia --utc
network --bootproto=dhcp --device=link --activate
rootpw --lock
selinux --enforcing
firewall --enabled

# systemd-boot é selecionado durante a própria instalação package-based.
bootloader --sdboot

# O ambiente é definido no comps próprio da composição. Assim, a seleção de
# software não depende dos ambientes genéricos da Fedora Everything.
%packages --excludedocs
@^fedora-gnome-minimal-environment
%end

%post --erroronfail --log=/root/fedora-gnome-minimal-install.log
# O primeiro boot precisa chegar ao GDM; o GNOME Initial Setup então cria o
# primeiro usuário. Não criar usuário aqui e não desbloquear root.
systemctl set-default graphical.target
systemctl enable gdm.service
systemctl disable NetworkManager-wait-online.service || true

install -d -m 0755 /usr/local/share/fedora-gnome-minimal
cat > /usr/local/share/fedora-gnome-minimal/installation-mode <<'EOF'
pungi-package-based
EOF
%end
