# rclone_sync简介

rclone_sync 是一个用于定时同步的脚本，利用 rclone 工具将文件从一个位置同步到另一个位置。此脚本可通过 curl 或 wget 下载并立即执行。**如果直接将rclone同步的命令加入crontab并设置每小时同步，会导致出现上次同步还没结束又开启新一轮同步的问题。该脚本增加了是否有同步进程的检测，可以规避这一问题。**

## 一键脚本
```
curl -s https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh | bash
```

## 依赖

- rclone
- Unix-like 操作系统
- curl 或 wget 工具


## rclone 配置
在使用此脚本之前，请确保你已经安装并配置好 rclone。你可以通过以下命令检查 rclone 是否安装：
```rclone --version```
如果 rclone 未安装或未配置，请参考 rclone 官方文档 进行安装和配置。

## 脚本手动执行、修改（不推荐）
```
curl -s https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh -o rclone_sync.sh
```
赋予执行权限
```
cd /root && chmod +x rclone_sync.sh
```
运行脚本
```
./rclone_sync.sh
```
修改脚本
```
nano /root/rclone_sync.sh
```

## 设置同步
```
echo -e "0 * * * * cd /root && ./rclone_sync.sh" | crontab -
```
该效果为每小时切换到 /root 目录并执行 rclone_sync.sh 脚本。

## 贡献
欢迎提交问题（Issues）和合并请求（Pull Requests）以改进此脚本。
