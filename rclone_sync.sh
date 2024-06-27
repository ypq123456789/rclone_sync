#!/bin/bash

# 日志文件路径
LOG_FILE="/root/rclone_sync.log"
# 命令参数文件路径
COMMAND_FILE="/root/rclone_command.txt"

# 检查是否安装了rclone，若未安装则进行安装
if ! command -v rclone &> /dev/null; then
    echo "rclone 未找到，正在安装..."
    echo "$(date) rclone 未找到，正在安装..." >> $LOG_FILE
    sudo -v && curl https://rclone.org/install.sh | sudo bash
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
config_file="/root/.config/rclone/rclone.conf"
if [ -f "$config_file" ];then
    echo "rclone 配置文件已存在。"
    echo "$(date) rclone 配置文件已存在。" >> $LOG_FILE
else
    echo "rclone 配置文件不存在，请提供配置文件的直链URL："
    read config_link
    if [ ! -z "$config_link" ]; then
        mkdir -p $(dirname "$config_file") && curl -L $config_link -o "$config_file"
        echo "已从 $config_link 下载rclone配置文件到 $config_file。"
        echo "$(date) 已从 $config_link 下载rclone配置文件到 $config_file。" >> $LOG_FILE
    fi
fi

# 函数：读取rclone sync命令的参数
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
    cat $COMMAND_FILE
    echo "如果您想要修改这些参数，请在10s内输入 'y'："
    read -t 10 modify_choice
    if [ "$modify_choice" == "y" ]; then
        # 用户选择修改参数
        read_command_params
    else
        echo "没有修改rclone sync命令。"
        echo "$(date) 没有修改rclone sync命令。" >> $LOG_FILE
    fi
fi

# 检查screen是否安装，若未安装则进行安装
if ! command -v screen &> /dev/null; then
    echo "未找到screen，正在安装..."
    echo "$(date) 未找到screen，正在安装..." >> $LOG_FILE
    sudo apt-get update && sudo apt-get install screen -y
else
    echo "screen已经安装。"
    echo "$(date) screen已经安装。" >> $LOG_FILE
fi

# 使用保存的命令参数执行rclone sync命令
command_params=$(cat $COMMAND_FILE)
echo "使用参数执行rclone命令：$command_params"
# 运行的具体rclone sync命令，使用screen在后台执行
screen -dmS rclone
screen -r rclone -X stuff "$command_params\n"
echo "进入rclone会话执行命令。"
echo "$(date) 进入rclone会话并执行命令。" >> $LOG_FILE

# 查看rclone日志
echo "查看rclone日志。"
echo "$(date) 查看rclone日志。" >> $LOG_FILE
sleep 3
watch -n 1 "tail -n 10 /root/rclone.log" &

# 等待任务完成
while pgrep -f "rclone sync" > /dev/null; do
    sleep 1
done

# 检查同步任务是否成功完成
if ! pgrep -f "rclone sync" > /dev/null; then
    echo "rclone sync 任务成功完成！"
    echo "$(date) 同步完成。" >> $LOG_FILE
else 
    echo "rclone sync 任务发生错误，请检查日志。"
    echo "$(date) 同步失败。" >> $LOG_FILE
fi
