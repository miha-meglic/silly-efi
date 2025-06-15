# Silly EFI "bootloader"

Required packages (build): `build-essential`, `gnu-efi`, `mtools`

Required packages (run): `qemu-system-x86`, `ovmf`

## Running

```bash
> sudo make                     # sudo is needed for some commands
> sudo chown <user> disk.img    # image is owned by root
> make run                      # run in VM (QEMU)
```

