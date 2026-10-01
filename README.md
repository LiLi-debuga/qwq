# 小樱大作战 iOS 版

## 怎么出 IPA

1. 注册/登录 GitHub
2. 新建一个私有仓库（名字随便，比如 sakura-planner）
3. 把整个文件夹里的所有文件推上去（GitHub网页直接传也行）
4. 点仓库顶部的 **Actions** 标签
5. 左边选 **Build unsigned IPA**
6. 点右边 **Run workflow** 按钮，选 main 分支，点 Run
7. 等大概 3-5 分钟，绿勾之后点进去，下面 Artifacts 里下载 `SakuraPlanner-IPA`
8. 解压得到 `小樱大作战.ipa`，用巨魔商店装

## 注意

- 不需要 Apple 开发者账号
- 不需要签名
- IPA 是未签名的，巨魔商店直接装
- 第一次打开会弹通知权限，必须允许
- 本地通知到点会弹，不需要后台运行
