#!/bin/bash
source "$(pwd)/common.sh"

# 设置临时目录
TMP_DIR=$(mktemp -d)
cleanup() {
	rm -rf "$TMP_DIR"
}
trap cleanup EXIT

# 下载必要临时文件
download() {
	if ! curl -fsSL "https://${MIRROR_URL}/distros.zip" -o "${TMP_DIR}/distros.zip"; then
		error_exit "无法下载资源文件" "Failed to download resources"
	fi
	if ! unzip -q "${TMP_DIR}/distros.zip" -d "${TMP_DIR}"; then
		error_exit "解压资源文件失败" "Failed to extract resources"
	fi
}

# 分发到对应的发行版脚本
dispatch() {
	source /etc/os-release
	local script_path
	case $ID in
		ubuntu)
			major_ver=$(echo $VERSION_ID | cut -d. -f1)
			if [ $major_ver -ge 24 ]; then
				script_path="distros/ubuntu24.sh"
			elif [ $major_ver -ge 22 || $major_ver -ge 20 ]; then
				script_path="distros/ubuntu.sh"
			else
				error_exit "不支持的 Ubuntu 版本：${VERSION_ID}" "Unsupported Ubuntu version: ${VERSION_ID}"
			fi
		;;
		rocky)
			major_ver=$(echo $VERSION_ID | cut -d. -f1)
			if [ $major_ver -eq 8 ]; then
				script_path="distros/rocky8.sh"
			elif [ $major_ver -eq 9 ]; then
				script_path="distros/rocky9.sh"
			else
				error_exit "不支持的 Rocky Linux 版本：${VERSION_ID}" "Unsupported Rocky Linux version: ${VERSION_ID}"
			fi
		;;
		debian)
			major_ver=$(echo $VERSION_ID | cut -d. -f1)
			if [ $major_ver -eq 12 ]; then
				script_path="distros/debian12.sh"
			elif [ $major_ver -eq 11 ]; then
				script_path="distros/debian11.sh"
			else
				error_exit "不支持的 Debian 版本：${VERSION_ID}" "Unsupported Debian version: ${VERSION_ID}"
			fi
		;;
		arch)
			script_path="distros/${ID}.sh"
		;;
		*)
			error_exit "不支持的系统：${ID}" "Unsupported distribution: ${ID}"
		;;
	esac
	if [ -f "$script_path" ]; then
		msg "检测到 ${PRETTY_NAME}" "Detected ${PRETTY_NAME}"
		source "$script_path"
	else
		error_exit "找不到发行版脚本：${script_path}" "Missing distribution script: ${script_path}"
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

download
dispatch
