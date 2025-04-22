# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{
  config,
  lib,
  pkgs,
  modulesPath,
  user,
  borna-fonts-src,
  ...
}:
let
  nixStoreOptimiseAutomatic = true;
  nixGCAutomatic = true;
  nixGCFrequency = "weekly";
  nixGCOptions = "--delete-older-than 14d";
  userDirectory = "/home/" + user.userName;
  userMusicDirectory = "/home/" + user.userName + "/Music";
  userGamesInstallationFilesDirectory = "/home/" + user.userName + "/Games/HDD";
  userBackupDirectory = "/home/" + user.userName + "/Backup";
  dotFilesDirectory = "/etc/nixos/dotfiles";
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

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

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = user.hostName; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true; # Easiest to use and most distros use this by default.
  # Some addiational networking settings.
  # networking.defaultGateway = "192.168.1.1";
  # networking.nameservers = [ "9.9.9.9" ];

  # Set your time zone.
  time.timeZone = user.timeZone;

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Allow unfree packages.
  nixpkgs.config.allowUnfree = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Configure keymap in X11
  services.xserver.xkb.layout = "us,ir";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  fonts.packages =
    let
      borna-fonts = pkgs.fetchzip {
        url = borna-fonts-src.url;
        hash = borna-fonts-src.hash;
        postFetch = ''
          find . -name '*.ttf' -exec install -m444 -Dt $out/share/fonts/borna-fonts {} \;
        '';
      };
    in
    with pkgs;
    [
      borna-fonts
      nerd-fonts.fira-code
    ];

  # Enable CUPS to print documents.
  services.printing.enable = true;

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

  # Enable graphics.
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable sound.
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;
  };
  # Increase latency to prevent crackling and drop (underruns)
  # services.pipewire.extraConfig.pipewire."92-low-latency" = {
  #   "context.properties" = {
  #     "default.clock.rate" = 48000;
  #     "default.clock.quantum" = 128;
  #     "default.clock.min-quantum" = 128;
  #     "default.clock.max-quantum" = 1024;
  #   };
  # };
  # services.pipewire.extraConfig.pipewire-pulse."92-low-latency" = {
  #   context.modules = [
  #     {
  #       name = "libpipewire-module-protocol-pulse";
  #       args = {
  #         pulse.min.req = "128/48000";
  #         pulse.default.req = "128/48000";
  #         pulse.max.req = "1024/48000";
  #         pulse.min.quantum = "128/48000";
  #         pulse.max.quantum = "1024/48000";
  #       };
  #     }
  #   ];
  #   stream.properties = {
  #     node.latency = "128/48000";
  #     resample.quality = 1;
  #   };
  # };
  # Noise canceling module for pipewire pulseaudio emulation.
  # services.pipewire.extraConfig.pipewire-pulse."99-echo-cancel" = {
  #   "context.modules" = [
  #     {
  #       name = "libpipewire-module-echo-cancel";
  #       args = {
  #         "library.name" = "aec/libspa-aec-webrtc";
  #         "capture.props" = {
  #           "node.name" = "alsa_card.pci-0000_00_1f.3";
  #         };
  #       };
  #     }
  #   ];
  # };
  services.pipewire.extraConfig.pipewire."97-null-sink" = {
    "context.objects" = [
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Null-Sink";
          "node.description" = "Null Sink";
          "media.class" = "Audio/Sink";
          "audio.position" = "FL,FR";
        };
      }
      {
        factory = "adapter";
        args = {
          "factory.name" = "support.null-audio-sink";
          "node.name" = "Null-Source";
          "node.description" = "Null Source";
          "media.class" = "Audio/Source";
          "audio.position" = "FL,FR";
        };
      }
    ];
  };
  services.pipewire.extraConfig.pipewire."98-virtual-mic" = {
    "context.modules" = [
      {
        name = "libpipewire-module-loopback";
        args = {
          "audio.position" = "FL,FR";
          "node.description" = "Mumble as Microphone";
          "capture.props" = {
            # Mumble's output node name.
            "node.target" = "Mumble";
            "node.passive" = true;
          };
          "playback.props" = {
            "node.name" = "Virtual-Mumble-Microphone";
            "media.class" = "Audio/Source";
          };
        };
      }
    ];
  };

  # Enable keyboard media keys (handled by Gnome)
  # sound.mediaKeys.enable = true;

  # Bluetooth (handled by Gnome)
  # hardware.bluetooth.enable = true;
  # hardware.bluetooth.hsphfpd.enable = true; # Allows for calls through bluetooth.
  # hardware.bluetooth.settings.General.Enable = "Source,Sink,Media,Socket";

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # Immutable users can't be changed, that includes their password.
  users.mutableUsers = false;
  users.users.${user.userName} = {
    description = user.email;
    isNormalUser = true;
    uid = 1000;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "lp"
      "scanner"
    ];
    hashedPassword = user.hashedPassword;
    # packages = with pkgs; [ ];
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    neovim
    helix
    nil
    nixfmt-rfc-style
    wget
    curl
    neofetch
    ripgrep
    htop
    tree
    exfat
    gparted
  ];
  programs.git.enable = true;
  programs.dconf.enable = true;
  programs.appimage.enable = true;
  programs.gamescope.enable = true;
  # programs.steam.enable = true;
  # programs.steam.gamescopeSession.enable = true;
  # programs.gamemode.enable = true;
  # services.clamav.scanner.enable = true;
  # services.clamav.updater.enable = true;
  # services.clamav.daemon.enable = true;

  services.tor.enable = true;
  services.tor.client.enable = true;
  # services.tor.settings = {
  #   UseBridges = true;
  #   ClientTransportPlugin = "obfs4 exec ${pkgs.obfs4}/bin/lyrebird";
  #   Bridge = "obfs4 IP:ORPort [fingerprint]";
  # };

  # Mumble server.
  services.murmur = {
    enable = true;
    bandwidth = 540000;
    bonjour = true;
    password = user.mumblePassword;
    autobanTime = 0;
  };

  programs.git.config = {
    init.defaultBranch = "main";
    core.editor = "hx";
    # Set autocrlf to true on windows, input or false on linux.
    # core.autocrlf = "input";
  };

  # Enable Android debug bridge.
  programs.adb.enable = true;

  home-manager.useUserPackages = true;
  home-manager.useGlobalPkgs = true;
  home-manager.users.${user.userName} =
    { lib, pkgs, ... }:
    {
      home.stateVersion = "23.11";

      home.packages = with pkgs; [
        firefox
        thunderbird
        tor-browser
        maestral
        maestral-gui
        keepassxc
        denaro
        libreoffice
        foliate
        xournalpp
        vlc
        gimp
        distrobox
        fzf
        eza
        usbutils
        pciutils
        lshw
        glxinfo
        tldr
        bat
        lazygit
        lutris
        bottles
        mangohud
        gnomeExtensions.appindicator
        gnomeExtensions.persian-calendar
        dconf-editor
        taplo
        obs-studio
        qbittorrent
        p7zip
        rar
        picard
        tun2socks
        dust
        mumble
        helvum
        easytag
        kdePackages.kdenlive
        wl-clipboard
        scrcpy
      ];

      nix.gc = {
        automatic = nixGCAutomatic;
        frequency = nixGCFrequency;
        options = nixGCOptions;
      };

      programs.git = {
        enable = true;
        userName = user.gitUser;
        userEmail = user.gitEmail;
      };
      programs.bash.enable = true;
      programs.nushell.enable = true;
      programs.starship.enable = true;
      programs.starship.enableNushellIntegration = true;
      programs.direnv.enable = true;
      programs.direnv.enableNushellIntegration = true;
      programs.bash.shellAliases = {
        ll = "ls -l";
        lla = "ls -lha";
        eza = "eza --icons --group-directories-first --git --git-repos --header --long";
        ezaa = "eza --icons --group-directories-first --git --git-repos --header --long --all";
        lg = "lazygit";
        sudo = "sudo ";
        noscd = "cd ${dotFilesDirectory}";
        nosug = "nixos-rebuild switch --flake ${dotFilesDirectory}";
        nosud = ''
          /usr/bin/env bash -c '
            cd ${dotFilesDirectory} &&
            [[ -z $(git status --porcelain) ]] &&
            nix flake update &&
            git add flake.lock &&
            git commit -m "Update flake.lock file"
          '
        '';
        vault = "cd ~/Dropbox/Vault && hx .";
        cdf = "cd $(find . -type d 2>/dev/null | fzf)";
        cdfr = "cd $(find / -type d 2>/dev/null | fzf)";
        lpkgs = "nix-store -q --references /var/run/current-system/sw";
      };

      home.file = {
        ".config/helix/config.toml".source = ./helix/config.toml;
        ".config/helix/languages.toml".source = ./helix/languages.toml;
      };

      dconf.settings = with lib.hm.gvariant; {
        "org/gnome/settings-daemon/plugins/power".sleep-inactive-ac-type = "nothing";
        "org/gnome/desktop/interface".color-scheme = "prefer-dark";
        "org/gnome/desktop/peripherals/touchpad" = {
          edge-scrolling-enabled = false;
          two-finger-scrolling-enabled = true;
          tap-to-click = true;
        };
        "org/gnome/desktop/input-sources" = {
          sources = [
            (mkTuple [
              "xkb"
              "us"
            ])
            (mkTuple [
              "xkb"
              "ir"
            ])
          ];
        };
        "org/gnome/settings-daemon/plugins/color".night-light-enabled = true;
        "org/gnome/mutter".dynamic-workspaces = false;
        "org/gnome/mutter".edge-tiling = true;
        "org/gnome/mutter/keybindings" = {
          toggle-tiled-left = [
            "<Super>Left"
            "<Alt><Super>h"
          ];
          toggle-tiled-right = [
            "<Super>Right"
            "<Alt><Super>l"
          ];
        };
        "org/gnome/desktop/wm/preferences".num-workspaces = 9;
        "org/gnome/shell" = {
          favorite-apps = [
            "firefox.desktop"
            "org.gnome.Console.desktop"
            "org.gnome.Nautilus.desktop"
            "org.gnome.Music.desktop"
          ];
          disable-user-extensions = false;
          enabled-extensions = [
            "appindicatorsupport@rgcjonas.gmail.com"
            "PersianCalendar@oxygenws.com"
          ];
          disabled-extensions = [ ];
        };
        "org/gnome/desktop/wm/keybindings" = {
          close = [
            "<Alt>F4"
            "<Super>q"
          ];
          toggle-on-all-workspaces = [ "<Super>u" ];
          always-on-top = [ "<Super>i" ];
          cycle-windows = [
            "<Alt>Escape"
            "<Super>j"
          ];
          cycle-windows-backward = [
            "<Shift><Alt>Escape"
            "<Super>k"
          ];
          maximize = [
            "<Super>Up"
            "<Alt><Super>k"
          ];
          unmaximize = [
            "<Super>Down"
            "<Alt><Super>j"
          ];
          move-to-workspace-1 = [ "<Shift><Super>1" ];
          move-to-workspace-2 = [ "<Shift><Super>2" ];
          move-to-workspace-3 = [ "<Shift><Super>3" ];
          move-to-workspace-4 = [ "<Shift><Super>4" ];
          move-to-workspace-5 = [ "<Shift><Super>5" ];
          move-to-workspace-6 = [ "<Shift><Super>6" ];
          move-to-workspace-7 = [ "<Shift><Super>7" ];
          move-to-workspace-8 = [ "<Shift><Super>8" ];
          move-to-workspace-9 = [ "<Shift><Super>9" ];
          switch-to-workspace-1 = [ "<Super>1" ];
          switch-to-workspace-2 = [ "<Super>2" ];
          switch-to-workspace-3 = [ "<Super>3" ];
          switch-to-workspace-4 = [ "<Super>4" ];
          switch-to-workspace-5 = [ "<Super>5" ];
          switch-to-workspace-6 = [ "<Super>6" ];
          switch-to-workspace-7 = [ "<Super>7" ];
          switch-to-workspace-8 = [ "<Super>8" ];
          switch-to-workspace-9 = [ "<Super>9" ];
        };
        "org/gnome/shell/keybindings" = {
          switch-to-application-1 = [ ];
          switch-to-application-2 = [ ];
          switch-to-application-3 = [ ];
          switch-to-application-4 = [ ];
          switch-to-application-5 = [ ];
          switch-to-application-6 = [ ];
          switch-to-application-7 = [ ];
          switch-to-application-8 = [ ];
          switch-to-application-9 = [ ];
        };
        "org/gnome/settings-daemon/plugins/media-keys".custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
        ];
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Super>t";
          command = "kgx";
          name = "Launch Kgx terminal";
        };
        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
          binding = "<Super>f";
          command = "firefox";
          name = "Launch Firefox browser";
        };
      };

      # Auto start maestral (dropbox client) on login.
      # https://maestral.app/docs/autostart
      systemd.user.services.maestral = {
        Unit = {
          Description = "Maestral daemon";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
        Service = {
          Type = "notify";
          NotifyAccess = "exec";
          ExecStart = "${pkgs.maestral}/bin/maestral start -f";
          ExecStop = "${pkgs.maestral}/bin/maestral stop";
          ExecStopPost = ''
            /usr/bin/env bash -c "if [ ''${SERVICE_RESULT} != success ]; \
            then notify-send Maestral 'Daemon failed'; fi"
          '';
          WatchdogSec = "30s";
        };
      };
      systemd.user.services.maestral_qt = {
        Unit = {
          Description = "Maestral GUI for system tray";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.maestral-gui}/bin/maestral_qt";
          Restart = "on-failure";
        };
      };
      systemd.user.services.thunderbird = {
        Unit = {
          Description = "Launch thunderbird automatically on login";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.thunderbird}/bin/thunderbird";
          Restart = "on-failure";
          RestartSec = "5";
        };
      };
    };

  # Example of a system wide systemd service definition.
  # systemd.services.maestral = {
  #   enable = true;
  #   unitConfig = {
  #     Description = "Maestral daemon";
  #   };
  #   serviceConfig = {
  #     Type = "notify";
  #     NotifyAccess = "exec";
  #     WatchdogSec = "30s";
  #     ExecStart = "${pkgs.maestral}/bin/maestral start -f";
  #     ExecStop = "${pkgs.maestral}/bin/maestral stop";
  #     ExecStopPost = ''
  #       /usr/bin/env bash -c "if [ ''${SERVICE_RESULT} != success ]; \
  #       then notify-send Maestral 'Daemon failed'; fi"
  #     '';
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Automatically upgrade system
  #system.autoUpgrade = {
  #  enable = true;
  #  channel = "https://nixos.org/channels/nixos-unstable";
  #};

  # Limit systemd logs size
  services.journald.extraConfig = ''
    SystemMaxUse=1G
    SystemMaxFileSize=100M
  '';

  # Automatically collect garbage packages
  nix.optimise.automatic = nixStoreOptimiseAutomatic;
  nix.gc = {
    automatic = nixGCAutomatic;
    dates = nixGCFrequency;
    options = nixGCOptions;
  };

  # Nix settings that should one day become useless hopefully.
  # Allows you to run various commands.
  # For example: 'nix flake update' to update flake.lock file.
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  nix.settings.trusted-users = [
    "root"
    "@wheel"
  ];

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall.allowedTCPPorts = [
    # Mumble Murmur server port
    64738
  ];
  networking.firewall.allowedUDPPorts = [
    # Mumble Murmur server port
    64738
  ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Enable common container config files in /etc/containers
  virtualisation.containers.enable = true;
  virtualisation = {
    podman = {
      enable = true;
      # Create a `docker` alias for podman, to use it as a drop-in replacement
      # dockerCompat = true;
      # Required for containers under podman-compose to be able to talk to each other.
      # defaultNetwork.settings.dns_enabled = true;
    };
  };

  # Useful other development tools
  # environment.systemPackages = with pkgs; [
  #  dive # look into docker image layers
  #  podman-tui # status of containers in the terminal
  #  docker-compose # start group of containers for dev
  #  podman-compose # start group of containers for dev
  # ];

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # Not supported in flakes!
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
