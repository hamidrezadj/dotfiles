{
  lib,
  config,
  modulesPath,
  user,
  ...
}:
let
  userMusicDirectory = "/home/" + user.userName + "/Music";
  userGamesInstallationFilesDirectory = "/home/" + user.userName + "/Games/HDD";
  userBackupDirectory = "/home/" + user.userName + "/Backup";
in
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Hardware configuration was copied here then modifed.
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/5da3ba58-d287-46b9-8580-9f797798aa5b";
    fsType = "btrfs";
    options = [
      "rw"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "subvol=@"
    ];
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/5da3ba58-d287-46b9-8580-9f797798aa5b";
    fsType = "btrfs";
    options = [
      "rw"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "subvol=@home"
    ];
    # This is required if the password file is stored in this subvolume.
    # neededForBoot = true;
  };

  fileSystems."/nix" = {
    device = "/dev/disk/by-uuid/5da3ba58-d287-46b9-8580-9f797798aa5b";
    fsType = "btrfs";
    options = [
      "rw"
      "noatime"
      "ssd"
      "discard=async"
      "space_cache=v2"
      "subvol=@nix"
    ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BD84-4B57";
    fsType = "vfat";
    options = [
      "rw"
      "relatime"
      "fmask=0077"
      "dmask=0077"
      "codepage=437"
      "iocharset=ascii"
      "shortname=mixed"
      "utf8"
      "errors=remount-ro"
    ];
  };

  fileSystems.${userMusicDirectory} = {
    device = "/dev/disk/by-uuid/3485a53e-3c45-41dd-bb8a-f0b669cb6a0d";
    fsType = "btrfs";
    options = [
      "noatime"
      "autodefrag"
      "subvol=@Music"
    ];
  };

  fileSystems.${userGamesInstallationFilesDirectory} = {
    device = "/dev/disk/by-uuid/3485a53e-3c45-41dd-bb8a-f0b669cb6a0d";
    fsType = "btrfs";
    options = [
      "noatime"
      "autodefrag"
      "subvol=@Games"
    ];
  };

  fileSystems.${userBackupDirectory} = {
    device = "/dev/disk/by-uuid/3485a53e-3c45-41dd-bb8a-f0b669cb6a0d";
    fsType = "btrfs";
    options = [
      "noatime"
      "autodefrag"
      "subvol=@Backup"
    ];
  };

  swapDevices = [
    {
      device = "/dev/disk/by-partuuid/eaebbb11-7f4e-1442-be20-2e522e1b6e55";
      randomEncryption.enable = true;
    }
  ];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp3s0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp2s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Enable nvidia free driver.
  hardware.nvidia.open = false;
  # Enable nvidia propriety driver.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.powerManagement.enable = true;

  # With current nvidia drivers, Firefox on Wayland is unstable.
  # environment.sessionVariables = {
  #   MOZ_ENABLE_WAYLAND = "0";
  # };
}
