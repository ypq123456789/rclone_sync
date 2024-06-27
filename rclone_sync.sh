#!/bin/bash

# 日志文件路径
LOG_FILE="/root/rclone_sync.log"
# 命令参数文件路径
COMMAND_FILE="/root/rclone_command.txt"

echo "---------------------------------------------" >> $LOG_FILE

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

# 启动 rclone sync 命令并将其放入后台运行
echo "$(date) 启动 rclone sync 命令并将其放入后台运行" >> $LOG_FILE
nohup bash -c "$(cat $COMMAND_FILE)" > /root/rclone.log 2>&1 &

# 启动日志监视进程
echo "$(date) 启动日志监视进程" >> $LOG_FILE
(
    previous_size=-1
    while true; do
        sleep 1  # 休眠一段时间，等待日志生成
        current_size=$(stat --format=%s "/root/rclone.log")
        if [ "$current_size" -eq "$previous_size" ]; then
            # 如果文件尺寸没有改变，则继续
            continue
        else
            # 打印日志的最新10行
            echo "更新的日志："
            tail -n 10 /root/rclone.log
            previous_size=$current_size
        fi
        # 检查 rclone sync 进程是否仍在运行
        if ! pgrep -f "rclone sync" > /dev/null; then
            echo "rclone sync 任务已结束，停止监视日志。"
            echo "$(date) rclone sync 任务已结束，停止监视日志。" >> $LOG_FILE
            break
        fi
    done
) &

wait

echo "rclone sync 任务和日志监视操作均已完成。"
echo "$(date) rclone sync 任务和日志监视操作均已完成。" >> $LOG_FILE
echo "---------------------------------------------" >> $LOG_FILE
