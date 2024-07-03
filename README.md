# rclone_sync简介

rclone_sync 是一个用于定时同步的脚本，利用 rclone 工具将文件从一个位置同步到另一个位置。

- **⚫如果直接将rclone同步的命令加入crontab并设置每小时同步，会导致出现上次同步还没结束又开启新一轮同步的问题。该脚本增加了是否有同步进程的检测，可以规避这一问题。**
- **⚫本脚本会自动帮你安装rclone。**
- **⚫本脚本支持自动更新。**
- **⚫本脚本支持用户自定义输入rclone sync命令（无须指定日志文件路径，脚本已经指定），并且支持修改命令**
- **⚫本脚本支持通过直链直接下载rclone二进制文件到相应位置，例如[支持阿里云盘openapi的rclone版本](https://github.com/pongfcnkl/rclone)。**
- **⚫本脚本支持通过直链直接下载配置文件到相应位置。**
- **⚫由于本脚本在前台执行同步任务，建议手动执行时在screen中执行。适合场景：某次任务执行的时候想进去看看进度；手动执行时不想一直挂在前台有焦虑。**

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
## rclone_command.txt配置
在这个脚本中，/root/rclone_command.txt 文件用于存储和读取 rclone sync 命令的参数。这个文件的主要作用是：
### 持久化存储：
当用户首次运行脚本并输入 rclone sync 命令参数时，这些参数会被保存到这个文件中。
在后续运行脚本时，可以直接从这个文件读取之前保存的参数，而不需要用户每次都重新输入。
### 方便修改：
脚本会检查这个文件是否存在。如果存在，它会显示当前保存的参数，并询问用户是否需要修改。
这样设计使得用户可以方便地查看和修改之前设置的 rclone sync 命令参数。
### 命令执行：
脚本最终执行 rclone sync 命令时，会直接读取这个文件中的内容作为命令参数。
### 灵活性：
通过将命令参数保存在单独的文件中，用户可以在不修改主脚本的情况下更改 rclone sync 的具体操作。
### 安全性：
将命令参数存储在单独的文件中，可以避免在主脚本中硬编码可能包含敏感信息的命令参数。

### 怎么写？
自行学习rclone文档。
### 举个例子：
```
rclone sync onedrive: aliapijiami: --timeout=0 --transfers=4 --buffer-size=256M -P --no-update-modtime -u --size-only --log-level ERROR --tpslimit 4
```

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
