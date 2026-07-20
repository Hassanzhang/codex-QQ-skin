# Codex QQ Skin

一个 macOS Codex 桌面端的复古 QQ 风格皮肤：蓝银双层标题栏、QQ 在线资料卡、三栏工作区和 Codex 伙伴面板。

## 使用

1. 完全退出 Codex。
2. 在此目录执行 `chmod +x *.sh`。
3. 执行 `./install.sh` 启动并注入皮肤。
4. 需要恢复时执行 `./restore.sh`。

安装后可执行 `./verify.sh` 确认实时注入状态，执行 `./doctor.sh` 检查 Codex 内置运行时、素材与当前会话。

皮肤只通过 `127.0.0.1` 的 Chromium DevTools Protocol 注入 renderer，不修改 Codex `.app`、`app.asar` 或签名。watcher 日志位于 `~/Library/Application Support/CodexQQSkin/`。

## 目录

```text
install.sh              安装/启动
restore.sh              停止并清理注入
verify.sh               验证实时注入状态
doctor.sh               检查运行时、资源和当前会话
runtime.sh              内置 Node 运行时发现
injector.js             注入入口
renderer-template.js    注入运行时模板
style.css               主样式
theme.json              文案、颜色和布局配置
assets/
  background.png        顶部背景图
  avatar.png            QQ 风格头像
  pet.png               Codex 伙伴
  frame.png             复古窗框
  audio/                可选提示音
```

修改 `theme.json`、`style.css` 或 `assets/` 后，重新执行 `./install.sh` 即可应用。主题配置中的 `image` 必须保持为相对此项目目录的路径。
