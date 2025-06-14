{
  config = "powerpc64-unknown-linux-gnuabielfv2";
  rust = {
    rustcTargetSpec = "powerpc64-unknown-linux-gnu";
  };
  #config = "powerpc64-unknown-linux-gnu";
  linux-kernel = {
    name = "ppc xenon";
    target = "zImage.xenon";
    autoModules = false;
    baseConfig = "xenon_defconfig";
    extraConfig = ''
      AUTOFS_FS y
      CFG80211 y
      FAT_FS y
      FUSE_FS y
      FW_LOADER_COMPRESS y
      FW_LOADER_COMPRESS_ZSTD y
      INPUT_EVDEV y
      INPUT_JOYDEV y
      JOYSTICK_XPAD y
      LEDS_CLASS y
      MAC80211 y
      PERF_EVENTS y
      RTL8XXXU y
      TUN y
      USB y
      VFAT_FS y
      WIRELESS y
      WLAN y
      WLAN_VENDOR_REALTEK y
    '';
  };
}