{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  nixConfig = {
    extra-substituters = [ "https://hydra.angeldsis.com/" ];
    extra-trusted-public-keys = [ "hydra.angeldsis.com-1:7s6tP5et6L8Y6sX7XGIwzX5bnLp00MtUQ/1C9t1IBGE=" ];
  };
  outputs = { self, nixpkgs }:
  let
    host = import nixpkgs { system = "x86_64-linux"; };
    linux = host.fetchurl {
      url = "https://github.com/rwf93/linux/archive/9bbbff4f7817e74f1e434b7bb2cd3801e1f9ff09.tar.gz";
      hash = "sha256-nOocvxz0gVh7ooCIRtyNlFyVOTbYYzhZ9SVIFFVx7ok=";
    };
    ppc64 = import nixpkgs {
      system = "x86_64-linux";
      crossSystem = import ./config/cross.nix;
      overlays = [ (import ./config/overlay.nix) ];
    };
  in {
    legacyPackages.powerpc64-linux = import nixpkgs { system = "powerpc64-linux"; overlays = [ (import ./config/overlay.nix) ]; };
    packages.powerpc64-linux = {
      gccgo = ppc64.buildPackages.gccgo.cc.overrideAttrs (old: {
        preInstall = "";
      });
      inherit (ppc64) debootstrap screen gnupg python3 nix systemd xterm mesa;
      inherit (ppc64.xorg) xorgserver xvfb;
      linux = (ppc64.buildLinux {
        src = linux;
        version = "6.5.0-xenon";
        enableCommonConfig = false;
        # TODO, kernelInstallTarget
      }).overrideDerivation (old: {
        installTargets = [ "install" "modules_install" ];
        postInstall = ''
          cp arch/powerpc/boot/zImage.xenon $out/
        '';
      });
      nixos = let
        eval = import (nixpkgs + "/nixos") {
          system = "x86_64-linux";
          configuration = {
            imports = [ ./configuration.nix ];
            fileSystems."/boot".label = "NIXOS_BOOT";
            nixpkgs.overlays = [
              (self': super: {
                linux_xenon = self.packages.powerpc64-linux.linux;
                linuxXenonPackages = self'.linuxPackagesFor self'.linux_xenon;
              })
            ];
          };
        };
      in eval.system // { inherit eval; };
      livecd = let
        eval = import (nixpkgs + "/nixos") {
          system = "x86_64-linux";
          configuration = {
            imports = [
              ./configuration.nix
              ./iso-image.nix
            ];
            nixpkgs.overlays = [
              (self': super: {
                linux_xenon = self.packages.powerpc64-linux.linux;
                linuxXenonPackages = self'.linuxPackagesFor self'.linux_xenon;
              })
            ];
          };
        };
      in eval.config.system.build.isoImage // { inherit eval; };
      nixos_tar = host.callPackage (nixpkgs + "/nixos/lib/make-system-tarball.nix") {
        fileName = "nixos_tar";
        storeContents = [
          {
            object = self.packages.powerpc64-linux.nixos;
            symlink = "/nixos";
          }
        ];
        contents = [];
      };
    };
  };
}