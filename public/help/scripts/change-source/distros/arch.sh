#!/bin/bash

prepare() {
	BACKUP_FILE="/etc/pacman.d/mirrorlist.bak"
	TARGET_FILE="/etc/pacman.d/mirrorlist"
}

execute() {
	msg "开始更换北大镜像源（Arch Linux）..." "Changing to PKU mirror for Arch Linux..."
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "备份原始文件？" "Backup original files?" || return
	fi
	cp -f "$TARGET_FILE" "$BACKUP_FILE"
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "应用镜像配置？" "Apply mirror configuration?" || return
	fi
	sed -i "1i Server = https://${MIRROR_URL}/archlinux/\\\$repo/os/\\\$arch" "$TARGET_FILE"
	if pacman -Syy --noconfirm >/dev/null 2>&1; then
		msg "镜像源更换成功！" "Mirror changed successfully!"
	else
		mv -f "$BACKUP_FILE" "$TARGET_FILE"
		error_exit "换源失败，已恢复原配置" "Mirror change failed, restored original configuration"
	fi
}

prepare
execute
