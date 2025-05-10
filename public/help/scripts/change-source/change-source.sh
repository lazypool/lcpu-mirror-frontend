#!/bin/bash
source "$(dirname "$0")/common.sh"

# 分发到对应的发行版脚本
dispatch() {
	source /etc/os-release
	local script_path
	case $ID in
		ubuntu)
			major_ver=$(echo $VERSION_ID | cut -d. -f1)
			if [ $major_ver -ge 24 ]; then
				script_path="$(dirname "$0")/distros/ubuntu24.sh"
			else
				script_path="$(dirname "$0")/distros/ubuntu22.sh"
			fi
			;;
		*)
			script_path="$(dirname "$0")/distros/${ID}.sh"
			;;
	esac
	if [ -f "$script_path" ]; then
		msg "检测到 ${PRETTY_NAME}" "Detected ${PRETTY_NAME}"
		source "$script_path"
	else
		error_exit "不支持的系统：${ID}" "Unsupported distribution: ${ID}"
	fi
}

# 解析参数
while [[ $# -gt 0 ]]; do
	case $1 in
		--interactive) INTERACTIVE=1; shift ;;
		--zh) set_language zh; shift ;;
		*) shift ;;
	esac
done

# 检查 root 权限
if [ $EUID -ne 0 ]; then
	error_exit "需要 root 权限，请使用 sudo 执行" "Requires root privileges, please use sudo"
fi

dispatch
