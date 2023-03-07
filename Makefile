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

.PHONY: clean
clean:
	rm -rf *.tmp efi.img
