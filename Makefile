.PHONY: all
all: busybox linux

.PHONY: busybox
busybox:
	$(MAKE) -C busybox

efi.img:
	truncate -s 300M efi.img
	mkfs.fat -F 32 efi.img
	mkdir efi.tmp
	mount efi.img efi.tmp
	cp -RT efi efi.tmp
	umount efi.tmp

filesystem.squashfs:
	fakeroot mksquashfs os.tmp filesystem.squashfs

hapi.iso:
	xorriso -as mkisofs -append_partition 2 0xef efi.img -o hapi.iso iso.tmp

iso.tmp:
	mkdir iso.tmp
	cp filesystem.squashfs iso.tmp

.PHONY: linux
linux:
	$(MAKE) -C linux

os.tmp:
	mkdir os.tmp
	cp busybox/busybox os.tmp/busybox

.PHONY: task-hapi.iso
task-hapi.iso:
	test -n "$$SUDO_USER"
	runuser -u "$$SUDO_USER" -- $(MAKE) busybox linux
	$(MAKE) efi.img
	runuser -u "$$SUDO_USER" -- $(MAKE) os.tmp filesystem.squashfs iso.tmp hapi.iso

.PHONY: task-qemu
task-qemu:
	qemu-system-x86_64 -bios OVMF.fd -drive file=hapi.iso,format=raw

.PHONY: clean
clean:
	rm -rf *.tmp efi.img filesystem.squashfs hapi.iso
