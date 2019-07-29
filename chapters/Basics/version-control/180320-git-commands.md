# git commands

## 初始化
- git init
- git clone
## 添加
- git add
    - `-u`
    - `-A`
    - `-N`

## 提交
- git commit
    -  `-m`
    -  `--amend`
    -  `--no-edit`
-  git push
    -  `-u`

## 暂存
- git stash
    - `-K`
    - `pop`
    - `apply`
    - `drop`
    - `show -p`
    - `clear`

## commit 操作
### 查看
- git show
    - `--stat`
- git log
    - `--pretty=oneline`
    - `[<base branch>] ^<branch>`
- git reflog

### rebase
-  git rebase
    - `-i`
    - `--continue`
    - `--abort`

### cherry-pick
- git cherry-pick
    - `--continue`
    - `--abort`

## 回退
- git reset
    - `HEAD`
    - `--soft`
    - `--hard`
- git revert

## 分支
- git branch
    - `-a`
    - `<branch>`
    - `--set-upstream origin/<branch>`
    - `--set-upstream-to=origin/<branch>`
-  git pull
    -  `-r`
-  git merge
    -  `--no-ff`
-  git checkout
    -  `-b <branch> [<remote-branch>]`
    -  `-f`
    -  `-- <file name>`
    -  `<branch|commit> -- <file name>`


---


# 创建仓库
git init

# 添加文件
git add	文件名（可用空格隔开）
git add -u	添加所有workspace的文件
git add -A 添加所有文件

# commit文件
git commit -m 	"描述"
- 禁用fast-faword ，使用 git merge --no-ff -m "description" branch-name
    - fast-faword ： 分支提交了修改，master没有提交，master合并分支，直接合并分支的修改，则fast-faward
	

# 显示仓库文件状态
git status	

# 显示修改的内容
git diff	文件名

# 版本回退
- git reset --hard 	HEAD^
- git reset --hard	HEAD~100
- git reset --hard	commit id


> - head代表当前版本，head^ 代表上个版本，head^^ 代表上两个版本，也可以用~加上数字表示之前的版本
> - commit id代表每个版本的id号
> - HEAD 是当前提交记录的符号名称 -- 其实就是你正在其基础进行工作的提交记录
> - ~指返回几代
> - ^指哪一个父提交

# rebase文件
`git rebase <branch>` 移动至指定提交上游
- rebase 就是取出当前head的提交记录，"复制"它们，然后把在别的某个地方放下来
	
- rebase --continue 执行add添加修改后的冲突文件，然后置于顶部
- rebase --skip
		Restart the rebasing process by skipping the current patch.
- rebase --abort
	

# 日志记录
git log
- `--prety==oneline` 命令代表简要显示，即版本号和描述
- `--pretty=format:'%h %Cgreen [%cn]: %C(cyan) %s'` 按照指定格式渲染

# 命令记录
git reflog

# 丢弃修改
`git checkout -- <file>`
- `--`命令表示丢弃修改，不添加的话，checkout表示切换分支
- 让这个文件回到最近一次 git commit 或 git add 时的状态
    - 如果修改后没有添加到暂存区，则回退到版本库
    - 如果放到暂存区后，又做了修改，则回退到暂存区内的状态
- `git reset HEAD <file>`  把暂存区的修改撤销掉（unstage），重新放回工作区，即取消本次add操作

# 删除文件
git rm 文件删除后可用版本回退，从版本库中获取到最新版本的文件

---

# 远程仓库

## 添加远程库
git remote add origin git@server-name:path/repo-name.git

## 推送至远程库
git push -u origin master
- 使用-u命令使本地master和远程master分支关联
- git push origin master

## 克隆远程仓库
git clone

---

# 分支管理

## 查看分支
git branch

## 创建分支
`git branch <name>`
	-f	直接让分支指向另一个提交eg : git branch -f master HEAD~3	强制指向某一个提交
	还可以指定在某个分支的某个提交上新建
	
切换分支
`git checkout <name>`
	切换到指定的修改版本，同时把head指向切换的版本

创建并切换
`git checkout -b <name>`

合并至当前分支
`git merge <name>`

删除分支
`git branch -d <name>`

查看分支合并情况
git log --graph

---
# 其他

## 存储工作区
git stash

## 参看工作区存储情况re
git stash list

## 恢复工作区
git stach apply  恢复而不删除存储
git stash pop  恢复并且删除存储

## 删除工作区
git stash clear
git stash drop id
