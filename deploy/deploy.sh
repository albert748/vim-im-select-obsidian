#!/usr/bin/env bash
# 构建并把插件部署到本机 Obsidian vault 的插件目录。
# 用法：deploy/deploy.sh [--force-data]
#   --force-data  用 deploy/data.json 覆盖 vault 里已有的 data.json（默认不覆盖）

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VAULT="${OBSIDIAN_VAULT_PATH:-$HOME/obvault}"
PLUGIN_DIR="$VAULT/.obsidian/plugins/vim-im-select"
FORCE_DATA="${1:-}"

if [ ! -d "$VAULT/.obsidian" ]; then
  echo "找不到 vault：$VAULT（可用 OBSIDIAN_VAULT_PATH 覆盖）" >&2
  exit 1
fi

cd "$REPO"
echo "== 构建 =="
npm run build

echo "== 部署到 $PLUGIN_DIR =="
mkdir -p "$PLUGIN_DIR"
cp main.js manifest.json "$PLUGIN_DIR/"

if [ "$FORCE_DATA" = "--force-data" ] || [ ! -f "$PLUGIN_DIR/data.json" ]; then
  cp deploy/data.json "$PLUGIN_DIR/data.json"
  echo "已写入 data.json（来自 deploy/data.json）"
else
  echo "保留现有 data.json（未覆盖；要覆盖加 --force-data）"
fi

echo "== 完成 =="
echo "如插件已在运行，需在 Obsidian 里重新加载插件（或完全退出后重开）。"
echo "若改过 flatpak 的 DBus 权限，必须完全重启 Obsidian 才会生效。"
