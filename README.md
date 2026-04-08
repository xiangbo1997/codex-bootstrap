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

## 新电脑首次安装检查清单

按下面顺序检查，能最快确认环境是否可用：

### 1. Codex CLI 是否可用
```bash
codex --help
```

### 2. GitHub CLI 是否已登录
如果你后续要拉取私有仓库或推送更新，建议先检查：

```bash
gh auth status
```

如未登录：

```bash
gh auth login -h github.com -p https
gh auth setup-git
```

### 3. Codex 初始化命令是否已进入 PATH
```bash
command -v codex-init-project
codex-init-project --help
```

如果找不到命令，重新加载 shell：

```bash
source ~/.zshrc
```

### 4. MCP 服务器是否齐全
```bash
codex mcp list
```

建议至少确认这些核心 MCP 可用：
- `sequential-thinking`
- `desktop-commander`
- `context7`
- `playwright`
- `exa`

### 5. 用一个临时目录做冒烟测试
```bash
mkdir -p /tmp/codex-bootstrap-demo
cd /tmp/codex-bootstrap-demo
codex-init-project .
find . -maxdepth 3 | sort
```

预期至少能看到：
- `AGENTS.md`
- `.codex/`
- `.agents/skills/`

### 6. 如需把项目注册为 trusted
```bash
codex-init-project --trust .
```

### 7. 常见问题
- `command not found: codex-init-project`：通常是 `~/.local/bin` 没进 PATH
- `Missing template directory`：说明 `~/.codex/templates/project-bootstrap` 没装好
- `gh auth status` 失败：重新执行 `gh auth login`
- `codex mcp list` 缺核心服务：按全局 `codex-init-protocol` 补装

## 从当前机器刷新仓库快照
```bash
./sync-from-local.sh
git add .
git commit -m "sync codex bootstrap"
git push
```
