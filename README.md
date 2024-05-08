These are my personal configuration files.
## NixOs
There's a flake available to configure the whole system all at once.
### Installation
1. Boot up in a live environment.
2. Partition and format and mount the disks to following points:
  - root partition: `/mnt`
  - home partition: `/mnt/home`
  - nix partition: `/mnt/nix`
  - boot partition: `/mnt/boot`
  - swap partition: `swapon /dev/Sdx`
3. Clone this repo into `/mnt/etc/nixos`.
``` bash
mkdir -p /mnt/etc/nixos
# Nixos default normal user has uid 1000 and gid 100 (users).
chown 1000:100 /mnt/etc/nixos
useradd -ou 1000 -g 100 -s $SHELL configurator
sudo -iu configurator
nix-shell -p git
cd /mnt/etc/nixos
git clone https://github.com/hamidrezadj/dotfiles.git
exit
exit
```
4. Create a nix flake git repo in `/mnt/etc/nixos/user` to add needed personal information.
```nix
# /mnt/etc/nixos/user/
# └── flake.nix
{
  description = "This flake houses personal information";
  inputs = { };
  outputs =
    { self }:
    let
      user = {
        name = "Your Full Name";
        email = "your_email@example.com";
        userName = "your_username";
        hostName = "your-host-name";
        timeZone = "Your/Timezone";
        hashedPassword = "your_user_login_hashed_password";
      };
    in
    user;
}
```
- Here's some help:
```bash
useradd -ou 1000 -g 100 -s $SHELL configurator
sudo -iu configurator
nix-shell -p git
cd /mnt/etc/nixos
mkdir user
touch user/flake.nix
mkpasswd -m SHA-512 'your_password_inside_quotes' >> flake.nix
vim flake.nix
git init -b main
git config user.name "Your Name"
git config user.email "your_email@exmaple.com"
git commit -c "Initialize respository"
exit
exit
```
5. Install the system `nixos-install --no-root-password --flake /mnt/etc/nixos/dotfiles#chosen-host-name`.
6. Reboot.
### Logins
- firefox
- thunderbird
- maestral (dropbox)
### Known Issues
These issues require manual intervention.
- Mouse moves out of bounds.
  Mitigation: Disable the the invisible frame buffer in display settings.
  `sudo lshw -c display`
  Gnome does this through the dbus in the backend. Making it declarative is non-trivial.
  `dbus-monitor --session "interface='org.gnome.Mutter.DisplayConfig'"`
  `dbus-send --session --print-reply --reply-timeout=2000 --type=method_call --dest=org.gnome.Mutter.DisplayConfig /org/gnome/Mutter/DisplayConfig org.freedesktop.DBus.Introspectable.Introspect`
  Here's the slightly outdated proposal:
  [https://wiki.gnome.org/Initiatives/Wayland/Gaps/DisplayConfig]
  See also:
  [https://github.com/jadahl/gnome-monitor-config]
  [https://github.com/maxwellainatchi/gnome-randr-rust]
