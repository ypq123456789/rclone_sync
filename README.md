# rclone_sync简介

rclone_sync 是一个用于定时同步的脚本，利用 rclone 工具将文件从一个位置同步到另一个位置。**如果直接将rclone同步的命令加入crontab并设置每小时同步，会导致出现上次同步还没结束又开启新一轮同步的问题。该脚本增加了是否有同步进程的检测，可以规避这一问题。**

## 依赖
- Unix-like 操作系统
- rclone
- curl
- screen

安装rclone
```
sudo -v ; curl https://rclone.org/install.sh | sudo bash
```
安装curl
```
sudo apt install curl
```
安装screen
```
sudo apt-get install screen
```
## rclone 配置
在使用此脚本之前，请确保你已经配置好 rclone。你可以通过以下命令检查 rclone配置：  
```
rclone config
```  
如果 rclone 未配置，请参考[rclone 官方文档](https://rclone.org/docs/)进行安装和配置。  

## 脚本执行
```
sudo curl -s https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh -o rclone_sync.sh
```
赋予执行权限
```
sudo chmod +x /root/rclone_sync.sh
```
运行脚本
```
sudo ./root/rclone_sync.sh
```
修改脚本
```
sudo nano /root/rclone_sync.sh
```
**把脚本里面下面这行中“rclone sync onedrive: aliapijiami: --transfers=4 --buffer-size=256M -P --no-update-modtime -u --size-only --log-file=/root/rclone.log --log-level DEBUG --tpslimit 4”修改为你自己的rclone同步命令，注意“--log-file=/root/rclone.log”不要改动！**
```
screen -r rclone -X stuff $'rclone sync onedrive: aliapijiami: --transfers=4 --buffer-size=256M -P --no-update-modtime -u --size-only --log-file=/root/rclone.log --log-level DEBUG --tpslimit 4\n'
```
## 设置同步
```
sudo echo -e "0 * * * * cd /root && ./rclone_sync.sh" | crontab -
```
该效果为每小时切换到 /root 目录并执行 rclone_sync.sh 脚本。

## 查看日志
查看rclone日志
```
watch -n 1 "tail -n 10 /root/rclone.log"
```

查看rclone_sync日志
```
cat /root/rclone_sync.log
```

## 贡献
欢迎提交问题（Issues）和合并请求（Pull Requests）以改进此脚本。
