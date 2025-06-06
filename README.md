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
Here's and example using fdisk:
```sh
lsblk
sudo fdisk /dev/nvme0n1
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
sudo mkfs.fat -F 32 -n efi /dev/nvme0n1p1
sudo mkswap -L swap /dev/nvme0n1p2
sudo mkfs.btrfs -L main /dev/nvme0n1p3

# Create BTRFS subvolumes
sudo mount /dev/disk/by-label/main /mnt
cd /mnt
sudo btrfs subvolume create @
sudo btrfs subvolume create @home
sudo btrfs subvolume create @nix
cd ~
sudo umount /mnt
```
### Installation
```sh
# Mount the filesystems
sudo mount -o subvol=/@ /dev/disk/by-label/main /mnt
sudo mkdir -p /mnt/nix
sudo mkdir -p /mnt/home
sudo mkdir -p /mnt/boot
sudo mount -o subvol=/@nix /dev/disk/by-label/main /mnt/nix
sudo mount -o subvol=/@home /dev/disk/by-label/main /mnt/home
sudo mount -o umask=077 /dev/disk/by-label/efi /mnt/boot
sudo swapon /dev/disk/by-label/swap

# Clone Git repositories
sudo mkdir -p /mnt/etc/nixos
# Nixos default normal user has uid 1000 (nixos) and gid 100 (users).
sudo chown 1000:100 /mnt/etc/nixos
cd /mnt/etc/nixos
# Nixos install environment has that normal user as default, so proceed with:
git clone https://github.com/hamidrezadj/dotfiles.git
git clone https://github.com/hamidrezadj/user_flake_template.git
# But if there's need to make one, here's how:
sudo useradd -ou 1000 -g 100 -s $SHELL nixos
sudo -iu nixos
git clone https://github.com/hamidrezadj/dotfiles.git
git clone https://github.com/hamidrezadj/user_flake_template.git
exit
```
