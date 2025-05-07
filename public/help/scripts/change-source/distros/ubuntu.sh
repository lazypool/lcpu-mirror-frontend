#!/bin/bash
source "$(dirname "$0")/../common.sh"

prepare() {
	VERSION_CODENAME=$(lsb_release -cs)
	BACKUP_FILE="/etc/apt/sources.list.bak"
	TARGET_FILE="/etc/apt/sources.list"
}

generate_sources() {
	cat <<EOF
deb ${MIRROR_URL}/ubuntu/ ${VERSION_CODENAME} main restricted universe multiverse
deb ${MIRROR_URL}/ubuntu/ ${VERSION_CODENAME}-updates main restricted universe multiverse
deb ${MIRROR_URL}/ubuntu/ ${VERSION_CODENAME}-backports main restricted universe multiverse
deb ${MIRROR_URL}/ubuntu/ ${VERSION_CODENAME}-security main restricted universe multiverse
EOF
}

execute() {
	msg "开始更换北大镜像源..." "Changing to PKU mirror..."

	if [ $INTERACTIVE -eq 1 ]; then
		confirm "Backup original sources?" "是否备份原配置文件？" || return
	fi
	cp -f "$TARGET_FILE" "$BACKUP_FILE"

	if [ $INTERACTIVE -eq 1 ]; then
		confirm "Generate new sources?" "是否生成新配置？" || return
	fi
	generate_sources > "$TARGET_FILE"

	if apt-get update -yqq >/dev/null 2>&1; then
		msg "镜像源更换成功！" "Mirror changed successfully!"
	else
		mv -f "$BACKUP_FILE" "$TARGET_FILE"
		error_exit "换源失败，已恢复原配置" "Mirror change failed, restored original configuration"
	fi
}

prepare
execute
