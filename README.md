# dotfiles

Cross-platform dotfiles for macOS and Linux with:

- `stow` for symlink management
- `brew bundle` for tool installation
- agent CLI bootstrap for tools not fully covered by brew on every OS
- local override files for machine-specific settings

## Quick start

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./script/bootstrap
```

This will:

1. install Homebrew if needed
2. install the tools declared in `Brewfile`
3. install Node through `nvm` using `.nvmrc`
4. install agent desktop/CLI tools and skills
5. apply tracked agent config defaults without overwriting local customizations
6. symlink configs into `$HOME` with `stow`

## Layout

Each top-level package is managed by `stow`:

- `home` -> files in `$HOME`
- `ghostty` -> `~/.config/ghostty`
- `nvim` -> `~/.config/nvim`
- `starship` -> `~/.config/starship.toml`
## Commands

Install packages and link configs:

```bash
./script/bootstrap
```

Link configs only:

```bash
./script/install
```

Remove linked configs:

```bash
./script/uninstall
```

## Local overrides

Keep machine-specific settings out of shared files.

Supported local overrides:

- `~/.zshrc.local`
- `~/.tmux.local.conf`
- `~/.wezterm.local.lua`

Typical override examples:

- machine-specific `PATH` entries
- local integrations such as iTerm shell integration
- version-pinned binaries that are not shared across every machine
- experimental aliases or secrets
- agent auth tokens, local MCP paths, and machine-specific trusted-project entries

## Conflict handling

`./script/install` does not delete existing files. It runs a `stow` preflight first and exits on conflicts so you can back up or remove existing dotfiles manually.

## Adding a new tool

1. create a new top-level package directory
2. place files in their final target layout inside that package
3. add the package name in `script/common.sh`
4. add the package install entry in `Brewfile` if needed

## Agent tooling

Bootstrap currently restores:

- `codex`
- `claude-code`
- `opencode`
- `cursor-agent`
- skills listed in `agents/.agents/skills/manifest.txt`

Tracked agent config defaults live in:

- `agents/.codex/config.toml`
- `agents/.claude/settings.json`
- `agents/.config/opencode/opencode.json`

These files are copied only when missing. Existing local agent config is not overwritten.

Only safe agent config is tracked. Auth files, history, caches, logs, session state, and trusted-project data are intentionally not stored in git.

## Docker

Bootstrap installs the Docker CLI and `docker-compose`.

- On Linux, that may be enough if a Docker daemon is already available.
- On macOS, this does not install a container runtime by itself.

If you want to run containers locally on macOS, also install and start one of:

- Docker Desktop
- Colima
- OrbStack

## Visibility

Bootstrap now prints:

- each major phase before it runs
- verbose Homebrew bundle output
- planned `stow` changes before applying them
- actual `stow` link operations
- a final tool summary showing what commands are available on `PATH`
