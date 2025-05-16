#!/bin/bash

prepare() {
	BACKUP_FILE="/etc/apt/sources.list.bak"
	TARGET_FILE="/etc/apt/sources.list"
}

execute() {
	msg "开始更换北大镜像源（Debian 11）..." "Changing to PKU mirror for Debian 11..."
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "备份原始文件？" "Backup original files?" || return
	fi
	cp -f "$TARGET_FILE" "$BACKUP_FILE"
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "应用镜像配置？" "Apply mirror configuration?" || return
	fi
	sed -i "s|http://deb\.debian\.org|https://${MIRROR_URL}|g" $TARGET_FILE
	sed -i "s|http://security\.debian\.org|https://${MIRROR_URL}|g" $TARGET_FILE
	if apt-get update -yqq >/dev/null 2>&1; then
		msg "镜像源更换成功！" "Mirror changed successfully!"
	else
		mv -f "$BACKUP_FILE" "$TARGET_FILE"
		error_exit "换源失败，已恢复原配置" "Mirror change failed, restored original configuration"
	fi
}

prepare
execute
