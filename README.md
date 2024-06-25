# rclone_sync简介

rclone_sync 是一个用于定时同步的脚本，利用 rclone 工具将文件从一个位置同步到另一个位置。此脚本可通过 curl 或 wget 下载并立即执行。

## 使用 curl 下载并执行

```
curl -s https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh | bash
```

## 使用 wget 下载并执行

```
wget -qO- https://raw.githubusercontent.com/ypq123456789/rclone_sync/main/rclone_sync.sh | bash
```

## 依赖

rclone、Unix-like 操作系统、curl 或 wget 工具

## rclone 配置
在使用此脚本之前，请确保你已经安装并配置好 rclone。你可以通过以下命令检查 rclone 是否安装：
```rclone --version```
如果 rclone 未安装或未配置，请参考 rclone 官方文档 进行安装和配置。

## 脚本执行
下载脚本并赋予执行权限后，你可以通过以下命令运行脚本：
```./rclone_sync.sh```
或者你可以直接在一行命令中下载并执行脚本，如上所述。

## 贡献
欢迎提交问题（Issues）和合并请求（Pull Requests）以改进此脚本。
