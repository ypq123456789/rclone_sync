#!/bin/bash

# 日志文件路径
LOG_FILE="/root/rclone_sync.log"
# 命令参数文件路径
COMMAND_FILE="/root/rclone_command.txt"

echo "---------------------------------------------" >> $LOG_FILE

# 检查是否存在定时任务
if ! crontab -l | grep -q "rclone_sync.sh"; then
    # 添加新的定时任务
    echo "未发现定时任务，正在添加新的定时任务..."
    (crontab -l ; echo "0 * * * * cd /root && ./rclone_sync.sh") | crontab -
    echo "$(date) 添加新的定时任务：0 * * * * cd /root && ./rclone_sync.sh" >> $LOG_FILE
else
    echo "已存在定时任务。"
    echo "$(date) 已存在定时任务。" >> $LOG_FILE
fi

# 检查是否安装了rclone，若未安装则进行安装
if ! command -v rclone &> /dev/null; then
    echo "rclone 未找到，正在安装..."
    echo "$(date) rclone 未找到，正在安装..." >> $LOG_FILE
    sudo apt install rclone -y
    # 询问是否更换rclone二进制文件
    echo "是否需要更换rclone的二进制文件？请在10s内输入直链网址，否则按回车继续。"
    read -t 10 binary_link
    if [ ! -z "$binary_link" ]; then
        echo "正在从 $binary_link 下载rclone并安装到 /usr/bin/rclone 下..."
        sudo curl -L $binary_link -o /tmp/rclone && sudo mv /tmp/rclone /usr/bin/rclone && sudo chmod +x /usr/bin/rclone
        echo "$(date) 从 $binary_link 下载并安装rclone到 /usr/bin/rclone。" >> $LOG_FILE
    fi
else
    echo "rclone已经安装。"
    echo "$(date) rclone已经安装。" >> $LOG_FILE
fi

# 检查rclone配置文件
echo "$(date) 检查rclone配置文件" >> $LOG_FILE
config_file="/root/.config/rclone/rclone.conf"
if [ -f "$config_file" ];then
    echo "rclone 配置文件已存在。"
    echo "$(date) rclone 配置文件已存在。" >> $LOG_FILE
else
    echo "rclone 配置文件不存在，请提供配置文件的直链URL："
    read config_link
    if [ ! -z "$config_link" ];then
        mkdir -p $(dirname "$config_file") && curl -L $config_link -o "$config_file"
        echo "已从 $config_link 下载rclone配置文件到 $config_file。"
        echo "$(date) 已从 $config_link 下载rclone配置文件到 $config_file。" >> $LOG_FILE
    fi
fi

# 函数：读取rclone sync命令的参数
echo "$(date) 读取rclone sync命令的参数" >> $LOG_FILE
read_command_params() {
    echo "请输入 rclone sync 命令（请不要设置日志文件路径，默认保存在/root/rclone.log）："
    read command_params
    # 保存用户输入的参数到文件，并追加固定的日志文件路径参数
    echo "$command_params --log-file=/root/rclone.log" > $COMMAND_FILE
}

# 如果参数文件存在则使用它，否则从用户输入中读取参数。
if [ ! -f $COMMAND_FILE ]; then
    # 读取用户输入的新参数
    read_command_params
else
    echo "使用保存的 rclone sync 命令参数。"
    echo "$(date) 使用保存的 rclone sync 命令参数。" >> $LOG_FILE
    command_params=$(cat $COMMAND_FILE)
    echo "当前参数为：$command_params"
    echo "如果您想要修改这些参数，请在10s内输入 'y'："
    read -t 10 modify_choice
    if [ "$modify_choice" == "y" ];then
        # 用户选择修改参数
        echo "$(date) 用户选择修改参数" >> $LOG_FILE
        read_command_params
    else
        echo "没有修改rclone sync命令。"
        echo "$(date) 没有修改rclone sync命令。" >> $LOG_FILE
    fi
fi

# 执行 rclone sync 命令
echo "$(date) 执行 rclone sync 命令" >> $LOG_FILE
bash -c "$(cat $COMMAND_FILE)"

echo "rclone sync 任务已完成。"
echo "$(date) rclone sync 任务已完成。" >> $LOG_FILE
echo "---------------------------------------------" >> $LOG_FILE
