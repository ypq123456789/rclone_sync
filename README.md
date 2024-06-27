# rclone_sync简介

rclone_sync 是一个用于定时同步的脚本，利用 rclone 工具将文件从一个位置同步到另一个位置。

- **⚫如果直接将rclone同步的命令加入crontab并设置每小时同步，会导致出现上次同步还没结束又开启新一轮同步的问题。该脚本增加了是否有同步进程的检测，可以规避这一问题。**
- **⚫本脚本支持您通过直链直接下载rclone二进制文件到相应位置，例如[支持阿里云盘openapi的rclone版本](https://github.com/pongfcnkl/rclone)。**
- **⚫本脚本会自动帮你安装rclone。**
- **⚫本脚本支持通过直链直接下载配置文件到相应位置。**
- **⚫由于本脚本在前台执行同步任务，建议在screen中执行**

## 依赖
- Unix-like 操作系统
- rclone
- curl
  
安装curl
```
sudo apt install curl
```


## rclone 配置
在使用此脚本之前，请确保你已经配置好 rclone。你可以通过以下命令检查 rclone配置：  
```
rclone config
```  
如果 rclone 未配置，请参考[rclone 官方文档](https://rclone.org/docs/)进行安装和配置。  

## 脚本执行
一键脚本
```
sudo curl -o /root/rclone_sync.sh -f https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh && chmod +x /root/rclone_sync.sh && cd /root && ./rclone_sync.sh
```
下载/更新脚本
```
sudo curl -o /root/rclone_sync.sh -f https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh
```
手动运行脚本
```
sudo cd /root && ./rclone_sync.sh
```
## 在screen中执行
安装screen
```
sudo apt-get install screen
```
创建并进入rclone窗口
```
screen -S rclone
```
在screen中执行脚本
```
sudo curl -o /root/rclone_sync.sh -f https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh && chmod +x /root/rclone_sync.sh && cd /root && ./rclone_sync.sh
```
脱离窗口
```
ctrl+A，然后按D
```
进入窗口
```
screen -r rclone
```
## 同步
**本脚本默认为您设置每小时**切换到 /root 目录并执行 rclone_sync.sh 脚本，命令如下
```
sudo echo -e "0 * * * * cd /root && ./rclone_sync.sh" | crontab -
```
如果你想要修改，使用以下命令自行编辑
```
sudo crontab -e
```
## 查看日志
查看rclone日志（建议在screen中执行脚本，回到主界面查看rclone日志）
```
watch -n 1 "tail -n 10 /root/rclone.log"
```

查看rclone_sync日志
```
tail -n 30 /root/rclone_sync.log
```

## 贡献
欢迎提交问题（Issues）和合并请求（Pull Requests）以改进此脚本。
