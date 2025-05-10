#!/bin/bash

# 全局配置
MIRROR_URL=${MIRROR_URL:-"mirrors.lcpu.dev"}
declare -g ZH_MODE=0
declare -g INTERACTIVE=0

# 初始化语言设置
set_language() {
	if [[ "$LANG" =~ "zh_CN" ]] || [[ "$1" == "zh" ]]; then
		ZH_MODE=1
	fi
}

# 消息打印函数
msg() {
	if [ $ZH_MODE -eq 1 ]; then
		echo -e "\033[34m$1\033[0m"
	else
		echo -e "\033[34m$2\033[0m"
	fi
}

# 错误处理
error_exit() {
	if [ $ZH_MODE -eq 1 ]; then
		echo -e "\033[31m错误：$1\033[0m" >&2
	else
		echo -e "\033[31mError: $1\033[0m" >&2
	fi
	exit 1
}

# 确认提示
confirm() {
	if [ $INTERACTIVE -eq 1 ]; then
		local prompt_en=$1
		local prompt_zh=$2
		if [ $ZH_MODE -eq 1 ]; then
			read -p "$prompt_zh [y/N] " -n 1 -r
		else
			read -p "$prompt_en [y/N] " -n 1 -r
		fi
		echo
		[[ $REPLY =~ ^[Yy]$ ]]
	else
		return 0
	fi
}
