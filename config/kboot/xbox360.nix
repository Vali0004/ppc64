{ config, pkgs, lib, ... }:

{
  options = {
    boot.loader.kboot = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
    };
  };
  config = lib.mkIf config.boot.loader.kboot.enable {
    system.boot.loader.id = "kboot";
    system.build.installBootLoader = pkgs.replaceVarsWith {
      inherit (pkgs) runtimeShell;

      src = ./update-kboot.sh;
      name = "update-kboot.sh";
      isExecutable = true;

      replacements = {
        crossShell = pkgs.runtimeShell;
        kbootTemplate = ./kboot.conf;
      };
    };
  };
}