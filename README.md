# KernelSU for Exynos9810

Supports Galaxy Note9 (N960N) or other model with Exynos 9810.  
Not actively maintained. Use at your own risk.

Some changes:
 - Removed all `warning-as-error` (To pass compiler, I'm newbie in android kernels)
 - Removed `-mgeneral-regs-only` (I don't know if there are some side-effects)
 - Changed version (`4.9.X-Kr0nus built by icybear`, may break some strict semver parsers lol)
 - KernelSU modifications (according to the official documentation, I haven't test Kprobe yet.)

# Build the kernel

Essential tools should be installed beforehand.

Or download image directly from Releases.

> *note*
> 
> For arch users: `sudo pacman -Sy base-devel git`

Follow these instructions:

```bash
git clone https://github.com/iceBear67/android_kernel_exynos9810_kernelsu exynos9810_ksu
cd exynos9810_ksu

export ARCH=arm64 # architecture
export ANDROID_MAJOR_VERSION=q # according to the Samsung documentation, but it doesn't matters.

make mrproper # clean up
make $CODENAME # where CODENAMEs are found in arch/arm64/configs. Like `exynos9810-crownlte_defconfig`
make menuconfig # this will open a TUI where you can adjust the settings.
# For this kernel, you need to set the `cross compiler prefix` which is in `General Setup`.
## Run this command to get the value: `echo $(pwd)/toolchain/aarch64-linux-android-8.x/bin/aarch64-linux-android-`.

# Or use this instead:
export CROSS_COMPILE=$(pwd)/toolchain/aarch64-linux-android-8.x/bin/aarch64-linux-android- # I haven't tried this.
```

After proper configuration:

```bash
make -j{CPU_CORE} # CPU_CORE is the number of compiler threads, should be the number of processors.
```

Once successfully built, the kernel image can be found in `arch/arm64/boot/Image`

# Build boot.img

The `Image` you got in the last step isn't an image file that can be flushed directly into BOOT.

Use `android-image-kitchen` to create the flushable one.

## Getting the original boot.img from your phone

Boot your phone into TWRP.

```bash
adb shell # connect to your phone
dd if=/dev/block/by-name/BOOT of=/sdcard/boot.img # type this into adb shell
exit # quit adb shell
adb pull /sdcard/boot.img
```

## Repack

```bash
mkdir kitchen
mv boot.img kitchen/
cd kitchen
unpackimg.sh ./boot.img # this script comes from android-image-kitchen
cp /path/to/Image/you/built ./split_img/boot.img-kernel

# Make sure SELinux is enforced
echo "androidboot.selinux=enforcing" > ./split_img/boot.img-cmdline 
# btw, selinux is enforcing by default unless you change something in the previous steps.
repackimg.sh # also comes from android-image-kitchen too.
```

Then you will get an `image-new.img`, which can be flushed into your phone by Heimdall.

> *note*
>
> You'd better dump a stock one or Magisk might annoy you.

# Flush boot.img

See the [KernelSU Documentation](https://kernelsu.org/guide/installation.html) if you already have root access.

If not, use `heimdall` (bootloader must be unlocked first.)

## Using Heimdall

Reboot your phone into `Download mode`.

> *warning*
>
> Back up your boot.img first!

```bash
heimdall flash --BOOT ./image-new.img
```

Once complete, your phone will reboot and should succcessfully boot into the system.
It's a good idea to install TWRP first, in case you run into Bootloop issues.

# Maybe some questions

## KernelSU is incompatible with Magisk's module system.

Use magisk or uninstall magisk in it's manager application.

## I don't have a backup

Use mine: https://github.com/iceBear67/android_kernel_exynos9810_kernelsu/releases/download/v0.7.4/boot-original.img

