# Dotfiles
This repository contains all the configuration files necessary for a functional Nixos system.
## Installing From Minimum Image
If minimum installation image is used, `nixos-help` command can be used to read the complete manual.
Using `setfont ter-v32n` command enables a larger font.
### Internet
Either use a wired connection through ethernet or usb tether, or use wpa_supplicant for wireless wi-fi connection. Either way you may need to do some manual configuration. These commands may be helpful.
```sh
# For Wi-Fi run these commands
sudo systemctl start wpa_supplicant
wpa_cli
# Run the following commands in the interactive shell.
scan
scan_results
add_network
set_network 0 ssid "network_ssid"
set_network 0 psk "network_password"
enable_network 0

# Manually configure ip addresses
ip address show
ip address flush dev interface_name(wlp12s0)
ip address add new_ip/prefix_len(192.168.43.215/16) broadcast + dev interface_name

# Manually configure ip routes
ip route show
ip route del PREFIX
ip route add default via gateway_address(192.168.43.1) dev interface_name

# Manually configure name resolver
echo "nameserver 9.9.9.9" > resolv.conf
sudo resolvconf -a interface_name < resolv.conf
```
### Quality of Life
Now that there is internet access, it is possible to add some packages that can help quality of life, for example:
```sh
nix-shell -p zellij git
```
### Disk Partition and Formatting
Here's an example using fdisk:
```sh
sudo -i
lsblk
fdisk /dev/nvme0n1
# GPT partition table
g
# EFI partition
n
  enter
  enter
  +0.5G
t
  enter
  1
# SWAP partition
n
  enter
  enter
  +8G
t
  enter
  19
# Main partition
n
  enter
  enter
  enter
# Save and quit
w

# Format the partitions
mkfs.fat -F 32 -n efi /dev/nvme0n1p1
mkswap -L swap /dev/nvme0n1p2
mkfs.btrfs -L main /dev/nvme0n1p3

# Create BTRFS subvolumes
mount /dev/disk/by-label/main /mnt
cd /mnt
btrfs subvolume create @
btrfs subvolume create @home
btrfs subvolume create @nix
cd ~
umount /mnt
```

### Installation
```sh
sudo -i
# Mount the filesystems
mount -o subvol=/@ /dev/disk/by-label/main /mnt
mkdir -p /mnt/nix
mkdir -p /mnt/home
mkdir -p /mnt/boot
mount -o subvol=/@nix /dev/disk/by-label/main /mnt/nix
mount -o subvol=/@home /dev/disk/by-label/main /mnt/home
mount -o umask=077 /dev/disk/by-label/efi /mnt/boot
swapon /dev/disk/by-label/swap

# Clone Git repositories
mkdir -p /mnt/etc/nixos
cd /mnt/etc/nixos
git clone https://github.com/hamidrezadj/dotfiles.git
git clone https://github.com/hamidrezadj/user_flake_template.git

# Configure the system
mv /mnt/etc/nixos/user_flake_template /mnt/etc/nixos/user
# Configure user variables
# Remember the hostName chosen.
# Also if a nixosVersion other than "stable" is chosen,
# it shoud be coordinated with the flake.nix file in dotfiles.
vim /mnt/etc/nixos/user/flake.nix
# Generate and configure hardware specefice code
sudo nixos-generate-config --root /mnt
rm /mnt/etc/nixos/configuration.nix
mv /mnt/etc/nixos/hardware-configuration.nix /mnt/etc/nixos/dotfiles/hostName.nix
vim /mnt/etc/nixos/dotfiles/hostName.nix
# Edit configuration file if necessary
vim /mnt/etc/nixos/dotfiles/configuration.nix
# Update and configure the lock file
nix flake update \
  --extra-experimental-features nix-command \
  --extra-experimental-features flakes \
  --flake /mnt/etc/nixos/dotfiles \
  --output-lock-file /mnt/etc/nixos/dotfiles/hostName.lock \
  --reference-lock-file /mnt/etc/nixos/dotfiles/hostName.lock
# nixos-install and nixos-rebuild don't support changing the flake.lock file
ln -s /mnt/etc/nixos/dotfiles/hostName.lock /mnt/etc/nixos/dotfiles/flake.lock

# Install Nixos
nixos-install --no-root-password --no-channel-copy \
  --flake /mnt/etc/nixos/dotfiles#hostName

# After installation
sudo mv /etc/nixos/dotfiles /home/userName/.config/dotfiles
sudo chown -R userName:users /home/userName/.config/dotfiles
```

## Updating the system
For minor updates the following command aliases can be used:
```sh
# Updating hostName.lock file to update flake inputs
nosud
# Only updating the user information input
nosud user
# Upgrading or modifying the system
sudo nosug
```
For major updates, the inputs of `flake.nix` file in dotfiles repository should be modified.

## Logins
- firefox
- thunderbird
- maestral (dropbox)
