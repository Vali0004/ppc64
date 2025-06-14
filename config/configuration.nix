{ pkgs, config, lib, ... }:

let
  common_keys = import ./../ssh_keys.nix;
  my_keys = import ./../ssh_keys_personal.nix;
in {
  imports = [
    ./kboot/xbox360.nix
  ];
  boot = {
    consoleLogLevel = 16;
    loader = {
      grub.enable = false;
      kboot.enable = true;
    };
    kernelPackages = pkgs.linuxXenonPackages;
    kernelParams = [
      "coherent_pool=16M"
      "console=tty1"
      "console=ttyS0,115200"
      "nokaslr"
      "video=xenonfb"
    ];
    plymouth.enable = false;
  };
  documentation.enable = false;

  environment.systemPackages = with pkgs; [
    (neofetch.override { x11Support = false; })
    pciutils
    screen
    usbutils
    config.boot.kernelPackages.perf
    evtest
    #gdb
    sysstat
    git
    nmap
    dtc
    speedtest-cli
    iperf3
    pv
  ];

  fileSystems = {
    "/boot" = {
      #device = "UUID=4AA3-EF9F";
      #device = "UUID=5521-7907";
    };
    "/" = {
      #device = "UUID=387e8327-4894-4aa1-8a88-b3f3a663bac2";
      device = "LABEL=NIXOS_ROOT";
      fsType = "ext4";
    };
  };
  fonts.enableDefaultPackages = false;

  hardware = {
    graphics.enable = false;
    firmware = with pkgs; [
      firmwareLinuxNonfree
    ];
  };

  nixpkgs = {
    crossSystem = import ./cross.nix;
    overlays = [ (import ./overlay.nix) ];
  };

  networking = {
    defaultGateway = "10.0.0.1";
    firewall.enable = false;
    hostId = "aacc9931";
    interfaces.eth0 = {
      ipv4.addresses = [{
        address = "10.0.0.204";
        prefixLength = 24;
      }];
    };
    nameservers = [ "75.75.75.75" ];
    wireless.enable = true;
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    trusted-users = [
      "root"
      "vali"
      "@wheel"
    ];
  };

  programs = {
    git.enable = true;
    ssh.enableAskPassword = false;
  };

  security.polkit.enable = false;
  services = {
    avahi = {
      enable = true;
      publish = {
        enable = true;
      };
    };
    libinput.enable = false;
    nscd.enableNsncd = false;
  
    openssh.enable = true;
  
    speechd.enable = false;
  
    toxvpn = {
      enable = true;
      localip = "10.42.1.5";
    };
  
    xserver = {
      enable = false;
      desktopManager = {
        xterm.enable = false;
        xfce.enable = false;
      };
      displayManager = {
        #defaultSession = "none+i3";
        lightdm.enable = false;
        #startx.enable = true;
      };
      windowManager.i3 = {
        #enable = true;
        extraPackages = with pkgs; [
          dmenu
          i3status
          i3lock
          #i3blocks
        ];
      };
    };
  };

  system.stateVersion = "25.05";

  systemd.shutdownRamfs.enable = false;
  
  time.timeZone = "America/Detroit";

  users.users = with common_keys; with my_keys; {
    root = {
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
    vali = {
      isNormalUser = true;
      extraGroups = [
        "wheel"
        "ipfs"
      ];
      openssh.authorizedKeys.keys = my_keys ++ common_keys;
    };
  };
  #virtualisation.libvirtd.enable = false;
}