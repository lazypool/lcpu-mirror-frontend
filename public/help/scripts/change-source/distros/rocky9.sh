#!/bin/bash
source "$(dirname "$0")/../common.sh"

prepare() {
	REPO_FILES=(
		"/etc/yum.repos.d/rocky.repo"
		"/etc/yum.repos.d/rocky-extras.repo"
	)
	BACKUP_DIR="/etc/yum.repos.d/backup.d"
}

execute() {
	msg "开始更换北大镜像源（Rocky Linux）..." "Changing to PKU mirror for Rocky Linux..."
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "备份原始文件？" "Backup original sources?" || return
	fi
	mkdir -p "$BACKUP_DIR"
	msg "备份配置文件中..." "Backing up repository files..."
	cp -f "${REPO_FILES[@]}" "$BACKUP_DIR"
	if [ $INTERACTIVE -eq 1 ]; then
		confirm "应用镜像配置？" "Apply mirror configuration?" || return
	fi
	for file in "${REPO_FILES[@]}"; do
		sed -i -e 's|^mirrorlist=|#mirrorlist=|g' \
			  -e "s|^#baseurl=http://dl.rockylinux.org|baseurl=https://${MIRROR_URL}|g" \
			  "$file"
	done
	if dnf clean all >/dev/null 2>&1 && dnf makecache >/dev/null 2>&1; then
		msg "镜像源更换成功！" "Mirror changed successfully!"
	else
		msg "正在恢复备份..." "Restoring backups..."
		cp -f "$BACKUP_DIR"/* /etc/yum.repos.d/
		error_exit "换源失败，已恢复原配置" "Mirror change failed, restored original configuration"
	fi
}

prepare
execute
