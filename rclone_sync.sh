#!/bin/bash

# 日志文件路径
LOG_FILE="/root/rclone_sync.log"

# 检查rclone是否已安装，若未安装则进行安装
if ! command -v rclone &> /dev/null; then
    echo "未找到rclone，正在安装..."
    echo "$(date) 未找到rclone，正在安装..." >> $LOG_FILE
    sudo -v && curl https://rclone.org/install.sh | sudo bash
else
    echo "rclone已经安装。"
    echo "$(date) rclone已经安装。" >> $LOG_FILE
fi

# 检查screen是否已安装，若未安装则进行安装
if ! command -v screen &> /dev/null; then
    echo "未找到screen，正在安装..."
    echo "$(date) 未找到screen，正在安装..." >> $LOG_FILE
    sudo apt-get update && sudo apt-get install screen -y
else
    echo "screen已经安装。"
    echo "$(date) screen已经安装。" >> $LOG_FILE
fi

# 检查是否存在正在运行的包含“rclone sync”的进程。
if pgrep -f "rclone sync" > /dev/null; then
    echo "已经有一个 'rclone sync' 进程在运行，退出脚本。"
    echo "$(date) 已经有一个 'rclone sync' 进程在运行，退出脚本。" >> $LOG_FILE
    exit 1
fi
echo "未找到正在运行的 'rclone sync' 进程，脚本执行。"
echo "$(date) 未找到正在运行的 'rclone sync' 进程，执行脚本。" >> $LOG_FILE

# 检查是否存在名为'rclone'的screen会话，如果不存在则创建。
if ! screen -list | grep -q "rclone"; then
    echo "创建名为 'rclone' 的新screen会话。"
    screen -dmS rclone
else 
    echo "名为 'rclone' 的screen会话已存在，继续执行。"
fi

# 进入rclone会话并执行命令
screen -r rclone -X stuff $'rclone sync onedrive: aliapijiami: --transfers=4 --buffer-size=256M -P --no-update-modtime -u --size-only --log-file=/root/rclone.log --log-level ERROR --tpslimit 4\n'
echo "进入rclone会话执行命令"
echo "$(date) 进入rclone会话并执行命令。" >> $LOG_FILE

# 查看rclone日志
echo "查看rclone日志"
echo "$(date) 查看rclone日志。" >> $LOG_FILE
sleep 3
watch -n 1 "tail -n 10 /root/rclone.log" &

# 等待任务完成
while pgrep -f "rclone sync" > /dev/null; do
    sleep 1
done

# 检查同步任务是否成功
if ! pgrep -f "rclone sync" > /dev/null; then
    echo "rclone同步任务成功完成！"
    echo "$(date) 同步完成。" >> $LOG_FILE
else 
    echo "rclone同步任务出现错误，请检查日志。"
    echo "$(date) 同步失败。" >> $LOG_FILE
fi
