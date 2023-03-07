.PHONY: all
all:
	$(MAKE) -C busybox
	$(MAKE) -C linux

efi.img:
	truncate -s 300M efi.img
	mkfs.fat -F 32 efi.img
	mkdir efi.tmp
	mount efi.img efi.tmp
	cp -RT efi efi.tmp
	umount efi.tmp

filesystem.squashfs:
	fakeroot mksquashfs os.tmp filesystem.squashfs

os.tmp:
	mkdir os.tmp
	cp busybox/busybox os.tmp/busybox

.PHONY: clean
clean:
	rm -rf *.tmp efi.img filesystem.squashfs
