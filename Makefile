EFIINC = /usr/include/efi
ARCH = x86_64
EFIINCS = -I$(EFIINC) -I$(EFIINC)/$(ARCH) -I$(EFIINC)/protocol
EFILIB = /usr/lib
EFI_CRT_OBJS = $(EFILIB)/crt0-efi-$(ARCH).o
EFI_LDS = $(EFILIB)/elf_$(ARCH)_efi.lds
CFLAGS = $(EFIINCS) -fno-stack-protector -fPIC -fshort-wchar -mno-red-zone -Wall -ffreestanding
LDFLAGS = -nostdlib -znocombreloc -T $(EFI_LDS) -shared -Bsymbolic -L $(EFILIB) $(EFI_CRT_OBJS)
TARGET = BOOTX64.EFI
SRC = main.c
OBJ = main.o
LINK = main.so
IMG = disk.img
ESP_DIR = esp
EFI_PATH = $(ESP_DIR)/EFI/BOOT

# Path to OVMF.fd (may vary by system)
OVMF = /usr/share/qemu/OVMF.fd

.PHONY: all run clean

all: $(TARGET) $(IMG)

$(OBJ): $(SRC)
	$(CC) $(CFLAGS) -c $< -o $@

$(LINK): $(OBJ)
	ld $(LDFLAGS) $(OBJ) -o $@ -lefi -lgnuefi

$(TARGET): $(LINK)
	objcopy -j .text -j .sdata -j .data -j .rodata -j .dynamic -j .dynsym \
	-j .rel -j .rela -j .rel.* -j .rela.* -j .reloc \
	--target=efi-app-x86_64 --subsystem=10 $(LINK) $@

$(IMG): $(TARGET)
	rm -rf $(ESP_DIR)
	mkdir -p $(EFI_PATH)
	cp $(TARGET) $(EFI_PATH)/
	# Create a 64MB FAT32 image
	dd if=/dev/zero of=$(IMG) bs=1M count=64
	mkfs.vfat $(IMG)
	mmd -i $(IMG) ::/EFI
	mmd -i $(IMG) ::/EFI/BOOT
	mcopy -i $(IMG) $(TARGET) ::/EFI/BOOT/BOOTX64.EFI

run: $(IMG)
	qemu-system-x86_64 -m 512 -drive format=raw,file=$(IMG) -bios $(OVMF) -net none

clean:
	rm -f $(OBJ) $(LINK) $(TARGET) $(IMG)
	rm -rf $(ESP_DIR)

