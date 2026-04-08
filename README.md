# codex-bootstrap

私有仓库：同步 Codex 全局指令、skills、project bootstrap 模板，以及 `codex-init-project`。

## 包含内容
- 全局指令：`codex/AGENTS.md`, `codex/instruction.md`
- 权限配置：`codex/settings.local.json`
- skills：`codex/skills/`
- 项目初始化模板：`codex/templates/project-bootstrap/`
- 全局命令：`bin/codex-init-project`

## 安装
```bash
git clone <private-repo-url>
cd codex-bootstrap
chmod +x install.sh sync-from-local.sh bin/codex-init-project
./install.sh
source ~/.zshrc
```

## 验证
```bash
command -v codex-init-project
codex-init-project --help
codex mcp list
```

## 从当前机器刷新仓库快照
```bash
./sync-from-local.sh
git add .
git commit -m "sync codex bootstrap"
git push
```
