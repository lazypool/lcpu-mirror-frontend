#!/bin/bash

prepare() {
	TARGET_FILES=(
		"/etc/apt/mirrors/debian.list"
		"/etc/apt/mirrors/debian-security.list"
	)
	BACKUP_DIR="/etc/apt/mirrors/backup.d"
}

execute() {
	msg "开始更换北大镜像源（Debian 12）..." "Changing to PKU mirror for Debian 12..."
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "备份原始文件？" "Backup original files?" || return
	fi
	mkdir -p "$BACKUP_DIR"
	msg "备份配置文件中..." "Backing up repository files..."
	cp -f "${TARGET_FILES[@]}" "$BACKUP_DIR"
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "应用镜像配置？" "Apply mirror configuration?" || return
	fi
	for file in "${TARGET_FILES[@]}"; do
		sed -i "s/deb.debian.org/${MIRROR_URL}/g" "$file"
	done
	if apt-get update -yqq >/dev/null 2>&1; then
		msg "镜像源更换成功！" "Mirror changed successfully!"
	else
		msg "正在恢复备份..." "Restoring backups..."
		cp -f "$BACKUP_DIR"/* /etc/apt/mirrors
		error_exit "换源失败，已恢复原配置" "Mirror change failed, restored original configuration"
	fi
}

prepare
execute
