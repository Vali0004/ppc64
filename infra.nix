let
  flake = builtins.getFlake (toString ./.);
in {
  network = {
    pkgs = import flake.inputs.nixpkgs { system = "x86_64-linux"; crossSystem = import ./config/cross.nix; };
  };
  r2d2box = {
    imports = [ 
      ./config/configuration.nix
    ];
    deployment.targetHost = "10.0.0.204";
    deployment.targetUser = "root";
    fileSystems."/boot".label = "NIXOS_BOOT";
    nixpkgs.overlays = [
      (self': super: {
        linux_xenon = flake.packages.powerpc64-linux.linux;
        linuxXenonPackages = self'.linuxPackagesFor self'.linux_xenon;
      })
    ];
  };
}