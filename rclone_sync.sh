# 日志文件路径
LOG_FILE="/root/rclone_sync.log"

# 检查是否存在包含 "rclone sync" 字样的进程
if pgrep -f "rclone sync" > /dev/null; then
    echo "已经有包含 'rclone sync' 的进程在运行，退出脚本。"
    echo "已经有包含 'rclone sync' 的进程在运行，退出脚本。at $(date)" >> $LOG_FILE
    exit 1
fi
echo "没有包含 'rclone sync' 的进程在运行，执行脚本。"
echo "没有包含 'rclone sync' 的进程在运行，执行脚本。at $(date)" >> $LOG_FILE

# 进入 rclone 窗口执行命令
screen -r rclone -X stuff $'rclone sync onedrive: aliapijiami: --transfers=4 --buffer-size=256M -P --no-update-modtime -u --size-only --log-file=/root/rclone.log --log-level DEBUG --tpslimit 4\n'
echo "进入 rclone 窗口执行命令"
echo "进入 rclone 窗口执行命令 at $(date)" >> $LOG_FILE

# 查看rclone日志
echo "查看rclone日志"
echo "查看rclone日志 at $(date)" >> $LOG_FILE
sleep 3
watch -n 1 "tail -n 10 /root/rclone.log"

# 等待任务完成
while pgrep -f "rclone sync" > /dev/null; do
    sleep 1
done

# 检查同步任务是否成功
pgrep -f "rclone sync"
if [ $? -eq 0 ]; then
    echo "rclone 同步任务成功完成！" 
    echo "Sync completed at $(date)" >> $LOG_FILE
else 
    echo "rclone 同步任务出现错误，请检查日志。" 
    echo "Sync failed at $(date)" >> $LOG_FILE
fi


