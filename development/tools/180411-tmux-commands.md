# tmux 简要笔记

> [速查表](https://gist.github.com/ryerh/14b7c24dfd623ef8edc7) [快捷键](https://blog.csdn.net/hcx25909/article/details/7602935)

## 几个概念

* session
* window
* pane

## Install

```bash
brew install tmux
yum install -y tmux 
apt-get install tmux
```

## cli commands

新建 Session

```bash
tmux

tmux new -s <session-name>
```

查看所有的 Session

```bash
tmux ls
```

回到指定的 Session

```bash
tmux a -t <session-name>

tmux a[t, ttach] [-t <session-name>]
```

杀死 Session

```bash
tmux kill-session -t <session-name>
```

## prefix commands

> $prefix: ctrl + b

session

```text
:new -s  # 创建新的 Session，其中 : 是进入 Tmux 命令行的快捷键
s        # 列出所有 Session，可通过 j, k, 回车切换
$        # 重命名 Session
d        # detach，退出 Tmux Session，回到父级 Shell
```

window

```text
c        # 创建 Window
<n>      # 切换到第 n 个 Window
p        # 切换到上个 Window
n        # 切换到下个 Window
,        # 为当前 Window 命名（cli操作会导致命名失效）
```

pane

```text
%        # 垂直切分 Pane
"        # 水平切分 Pane
方向键   # 切换 Pane
x        # 关闭当前 Pane
<space>  # 切换 Pane 布局
{, }     # 切换 Pane 的顺序
```

others

```text
t        # 显示一个时钟
?        # 快捷键帮助列表
```

