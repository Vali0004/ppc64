#! @crossShell@

function addEntry() {
  ln -svf $1/init /init
  cp -vL $1/initrd /boot/initrd
  cp -vL $1/kernel /boot/zImage.xenon
  echo $2=\"sda0:/zImage.xenon initrd=sda0:/initrd init=$1/init $(cat $1/kernel-params)\" >> /boot/kboot.tmp
}

cp @kbootTemplate@ /boot/kboot.tmp

readarray -d '' generations < <(printf '%s\0' /nix/var/nix/profiles/system-*-link | sort -zV)
for generation in "${generations[@]}"; do
  echo $generation
done

addEntry "$1" nixos_latest

echo 'default=nixos_latest' >> /boot/kboot.tmp

mv /boot/kboot.tmp /boot/kboot.conf