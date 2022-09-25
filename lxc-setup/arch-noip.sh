# Enable NTP
timedatectl set-ntp true

# Setup Pacman, Update, then Install git, sudo and base-devel
pacman-key --init
pacman-key --populate archlinux

cpu_arch=$(lscpu | grep Architecture | cut -d':' -f2 | sed 's/ *//g')
if [[ $cpu_arch = "x86_64" ]]; then
	mirrorlist_url="https://archlinux.org/mirrorlist/?country=US&protocol=https&ip_version=4&use_mirror_status=on"
else
	echo "Unable to identify cpu architecture for mirrorlist url."
	exit;
fi

curl -s ${mirrorlist_url} -o /etc/pacman.d/mirrorlist
sed -e 's/^#Server/Server/' -e '/^#/d' -i /etc/pacman.d/mirrorlist
pacman -Syy --noconfirm archlinux-keyring
pacman -Syu --noconfirm

pacman -Syy --noconfirm sudo git base-devel

# Install trizen and noip from aur with temp account
echo '%wheel ALL=(ALL) NOPASSWD: ALL' > /etc/sudoers.d/wheel-nopasswd
useradd -g users -G users,wheel,storage,video -m -s /bin/bash pacmantemp
su - pacmantemp -c 'git clone https://aur.archlinux.org/trizen.git && cd trizen && makepkg -si --skipinteg --noconfirm'
su - pacmantemp -c 'trizen -S --skipinteg --noconfirm noip'
userdel -f -r pacmantemp
test -d /home/pacmantemp && rm -Rf /home/pacmantemp
rm /etc/sudoers.d/wheel-nopasswd

# Configure and Enable noip
noip2 -C -Y
systemctl enable noip2 && systemctl start noip2
