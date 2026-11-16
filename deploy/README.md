# 本 fork 的用途（Linux + fcitx5-rime）

上游：[ALONELUR/vim-im-select-obsidian](https://github.com/ALONELUR/vim-im-select-obsidian)（MIT）。
本仓库 = 上游 `master` + 下面两项，用于在 Linux（KDE Wayland + fcitx5 + fcitx5-rime + Flatpak 版 Obsidian）上让 Vim 模式自动切换中英。

已提交上游：[PR #39](https://github.com/ALONELUR/vim-im-select-obsidian/pull/39)。

## 相对上游多了什么

| 提交 | 内容 |
|---|---|
| `fix: harden vim-mode lookup and honour replace mode` | `getActiveView()` 返回类型改 `MarkdownView \| null`；`active-leaf-change` 里 `editor.state.vim` 空指针；`R`（replace）按插入模式处理 |
| `feat: add Insert IM setting and resync IME on window focus` | 新增 `insertIM` 设置项（issue #11）；窗口重新获得焦点时按当前 vim 模式重新同步 |
| `chore: 本地部署资产` | `deploy/` 下的配置样板与部署脚本；`main.js` 构建产物入库，重装后不必重新构建 |

## 为什么 Linux 要这样配

`im-select.exe` 是 Windows 专用；Linux 侧用 fcitx5-rime 的 DBus 接口切 **rime 的 ascii 模式**，语义与 vim 的 normal/insert 一一对应，且不像 `fcitx5-remote -s <im>` 那样影响其他应用。

Obsidian 若是 Flatpak 版，沙箱内既没有 `fcitx5-remote` 也不被允许访问 fcitx5 的会话总线名，需要一条最小权限：

```bash
flatpak override --user --talk-name=org.fcitx.Fcitx5 md.obsidian.Obsidian
```

该权限只在进程启动时应用 ⇒ 改完必须**完全退出 Obsidian 再启动**。

## data.json 字段含义（`deploy/data.json`）

| 字段 | 值 | 含义 |
|---|---|---|
| `defaultIM` | `true` | normal 模式 → `SetAsciiMode true`（英文，vim 键可用） |
| `insertIM` | `false` | insert / replace 模式 → `SetAsciiMode false`（中文） |
| `obtainCmd` | `printf false` | 固定值；**不要**换成 `IsAsciiMode`，其输出带 `(…)` 且与切换命令存在执行竞态 |
| `switchCmd` | `gdbus call … SetAsciiMode {im}` | `{im}` 被上面两个布尔值替换 |

`windows*` 三项保留给 Windows 端（vault 跨机同步时那边仍走 `im-select.exe`）。

## 构建环境（换机复现要点）

- Node 22 / npm 12 实测可用。
- `npm install` 会看到 `esbuild@0.19.10 (postinstall: node install.js)` 被 npm 的 allowScripts 拦下 —— **不影响构建**：esbuild 的真实二进制来自 optional dependency `@esbuild/linux-x64/bin/esbuild`（约 9.6 MB），不依赖 postinstall。只有撞到 "You installed esbuild for another platform" 一类报错时才需要 `npm install-scripts approve esbuild`。
- 构建验证：`npm run build && ls -l main.js`（约 9.7 KB）。

## 部署

```bash
deploy/deploy.sh              # 构建 + 部署，保留现有 data.json
deploy/deploy.sh --force-data # 连 data.json 一起覆盖
```

## 上游同步

```bash
git fetch upstream && git rebase upstream/master
```

上游若合并了 PR #39，本仓库的对应提交可以直接丢弃。
